/*
 * RautorViewerView.java Author: Angelos Karageorgiou angelos@unix.gr
 * Ah fill in the blanks :-)
 */

package rautorviewer;


import org.jdesktop.application.Action;
import org.jdesktop.application.ResourceMap;
import org.jdesktop.application.SingleFrameApplication;
import org.jdesktop.application.FrameView;
import org.jdesktop.application.TaskMonitor;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import javax.swing.Timer;
import javax.swing.Icon;
import javax.swing.JDialog;
import javax.swing.JFrame;
import javax.swing.JFileChooser;
import javax.swing.ImageIcon;
import javax.swing.JSlider;
import java.io.*;
import java.util.Arrays;
import java.util.regex.*;
import javax.swing.JCheckBoxMenuItem;
import javax.imageio.*;
import java.awt.Image;
import java.awt.event.KeyEvent;
import java.nio.charset.Charset;
import java.util.Locale;
import javax.swing.JRadioButtonMenuItem;
import javax.swing.KeyStroke;
import javax.swing.JComponent;


/**
 * The application's main frame.
 */
public class RautorViewerView extends FrameView {

    // Global Class variables
    // When I grow up I will turn it into a message passing system :-)
        File LastSessiondir;
//        FileObject LastFtpSessiondir;
        String[] Files;
        String FullPath,FullFtpPath;
        Boolean FollowToggled=false,Running=false,Replay=false;
        Thread WorkerT,video;
        int VideoIndex=0,VideoLast=0;
        boolean scale=false;
        String AppName="RautorViewer";
        Boolean FitImages=false;
        Boolean AspectFixed=false;
        int ZoomAlgorithm=2,ScreenContentsHighlightStart=0,ScreenContentsHighlightEnd=0;
        public static String SearchText="",CurrentScreenContents="",ScreenContents="";
        boolean EscapedSearch=false;
        boolean SessionIsRemote=false;
        String localCharset = Charset.defaultCharset().toString();
       
    public RautorViewerView(SingleFrameApplication app) {
        super(app);

        initComponents();
        
        jScrollPane1.setMaximumSize(null);
        // Start Follower Thread
        try {
               WorkerT = new Thread(new Worker());
               WorkerT.start();
        } catch (Exception e) {
               statusMessageLabel.setText("Could not start Worker thread");
        }

        // Start Video Thread
        try {
            video=new Thread(new Player());
            video.start();
        } catch (Exception e) {
            statusMessageLabel.setText("Cannot spawn Video player");
        }
        
        jLabel1.setText(null);
        statusMessageLabel.setText(null);
        StopReplayButton.setEnabled(false);
        StartReplayButton.setEnabled(false);
        VideoSlider.setEnabled(false);
        FollowButton.setEnabled(false);

        localCharset=LocaleToCharsetMap.getCharset(Locale.getDefault());    
      

        // status bar initialization - message timeout, idle icon and busy animation, etc
        ResourceMap resourceMap = getResourceMap();
        int messageTimeout = resourceMap.getInteger("StatusBar.messageTimeout");
        messageTimer = new Timer(messageTimeout, new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                statusMessageLabel.setText("");
            }
        });
        messageTimer.setRepeats(true);
        messageTimer.start();
        int busyAnimationRate = resourceMap.getInteger("StatusBar.busyAnimationRate");
        for (int i = 0; i < busyIcons.length; i++) {
            busyIcons[i] = resourceMap.getIcon("StatusBar.busyIcons[" + i + "]");
        }
        busyIconTimer = new Timer(busyAnimationRate, new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                busyIconIndex = (busyIconIndex + 1) % busyIcons.length;
                statusAnimationLabel.setIcon(busyIcons[busyIconIndex]);
            }
        });
        idleIcon = resourceMap.getIcon("StatusBar.idleIcon");
        statusAnimationLabel.setIcon(idleIcon);
        progressBar.setVisible(true);

        // connecting action tasks to status bar via TaskMonitor
        TaskMonitor taskMonitor = new TaskMonitor(getApplication().getContext());
        taskMonitor.addPropertyChangeListener(new java.beans.PropertyChangeListener() {
            public void propertyChange(java.beans.PropertyChangeEvent evt) {
                String propertyName = evt.getPropertyName();
                if ("started".equals(propertyName)) {
                    if (!busyIconTimer.isRunning()) {
                        statusAnimationLabel.setIcon(busyIcons[0]);
                        busyIconIndex = 0;
                        busyIconTimer.start();
                    }
                    progressBar.setVisible(true);
                    progressBar.setIndeterminate(true);
                } else if ("done".equals(propertyName)) {
                    busyIconTimer.stop();
                    statusAnimationLabel.setIcon(idleIcon);
                    progressBar.setVisible(false);
                    progressBar.setValue(0);
                } else if ("message".equals(propertyName)) {
                    String text = (String)(evt.getNewValue());
                    statusMessageLabel.setText((text == null) ? "" : text);
                    messageTimer.restart();
                } else if ("progress".equals(propertyName)) {
                    int value = (Integer)(evt.getNewValue());
                    progressBar.setVisible(true);
                    progressBar.setIndeterminate(false);
                    progressBar.setValue(value);
                }
            }
        });

        KeyStroke strokeEsc = KeyStroke.getKeyStroke(KeyEvent.VK_ESCAPE, 0);
        mainPanel.registerKeyboardAction(actionListenerEsc, strokeEsc, JComponent.WHEN_IN_FOCUSED_WINDOW);
    }

ActionListener actionListenerEsc = new ActionListener() {
        public void actionPerformed(ActionEvent actionEvent) {
            EscapedSearch=true;
        }
};
/*
 *******************************************
 */
    @Action
    public void showAboutBox() {
        if (aboutBox == null) {
            JFrame mainFrame = RautorViewerApp.getApplication().getMainFrame();
            aboutBox = new RautorViewerAboutBox(mainFrame);
            aboutBox.setLocationRelativeTo(mainFrame);
        }
        RautorViewerApp.getApplication().show(aboutBox);
    }
/*
 *******************************************
 */
    public void showEditorBox(String Title,String MyContents,int Start,int End) {
        JDialog textViewer;

        JFrame mainFrame = RautorViewerApp.getApplication().getMainFrame();
        textViewer = new RautorViewerTextBox(mainFrame,MyContents,Start,End);
        textViewer.setLocationRelativeTo(mainFrame);
        textViewer.setTitle(AppName + "  " + Title);
        RautorViewerApp.getApplication().show(textViewer);
    }

    /** This method is called from within the constructor to
     * initialize the form.
     * WARNING: Do NOT modify this code. The content of this method is
     * always regenerated by the Form Editor.
     */
    @SuppressWarnings("unchecked")
    // <editor-fold defaultstate="collapsed" desc="Generated Code">//GEN-BEGIN:initComponents
    private void initComponents() {

        mainPanel = new javax.swing.JPanel();
        jScrollPane1 = new javax.swing.JScrollPane();
        jLabel1 = new javax.swing.JLabel();
        menuBar = new javax.swing.JMenuBar();
        javax.swing.JMenu fileMenu = new javax.swing.JMenu();
        jMenuItem8 = new javax.swing.JMenuItem();
        jMenuItem3 = new javax.swing.JMenuItem();
        javax.swing.JMenuItem exitMenuItem = new javax.swing.JMenuItem();
        jMenu1 = new javax.swing.JMenu();
        jMenuItem4 = new javax.swing.JMenuItem();
        jMenuItem5 = new javax.swing.JMenuItem();
        jSeparator1 = new javax.swing.JSeparator();
        jMenuItem2 = new javax.swing.JMenuItem();
        jMenu2 = new javax.swing.JMenu();
        FitImagesMenuItem = new javax.swing.JCheckBoxMenuItem();
        AspectRatioMenuItem = new javax.swing.JCheckBoxMenuItem();
        jMenu3 = new javax.swing.JMenu();
        jRadioButtonMenuItem3 = new javax.swing.JRadioButtonMenuItem();
        jRadioButtonMenuItem1 = new javax.swing.JRadioButtonMenuItem();
        jRadioButtonMenuItem2 = new javax.swing.JRadioButtonMenuItem();
        jMenu4 = new javax.swing.JMenu();
        SearchMenuItem = new javax.swing.JMenuItem();
        jMenuItem6 = new javax.swing.JMenuItem();
        javax.swing.JMenu helpMenu = new javax.swing.JMenu();
        javax.swing.JMenuItem aboutMenuItem = new javax.swing.JMenuItem();
        statusPanel = new javax.swing.JPanel();
        statusMessageLabel = new javax.swing.JLabel();
        statusAnimationLabel = new javax.swing.JLabel();
        progressBar = new javax.swing.JProgressBar();
        VideoSlider = new javax.swing.JSlider();
        StopReplayButton = new javax.swing.JButton();
        jSpinner1 = new javax.swing.JSpinner();
        StartReplayButton = new javax.swing.JButton();
        FollowButton = new javax.swing.JToggleButton();
        KeyLog = new javax.swing.JTextField();
        jSeparator2 = new javax.swing.JSeparator();
        jButton1 = new javax.swing.JButton();
        jPanel1 = new javax.swing.JPanel();
        buttonGroup1 = new javax.swing.ButtonGroup();

        org.jdesktop.application.ResourceMap resourceMap = org.jdesktop.application.Application.getInstance(rautorviewer.RautorViewerApp.class).getContext().getResourceMap(RautorViewerView.class);
        mainPanel.setBackground(resourceMap.getColor("mainPanel.background")); // NOI18N
        mainPanel.setBorder(new javax.swing.border.MatteBorder(null));
        mainPanel.setName("mainPanel"); // NOI18N
        mainPanel.setPreferredSize(new java.awt.Dimension(0, 0));

        jScrollPane1.setBackground(new java.awt.Color(153, 153, 153));
        jScrollPane1.setName("jScrollPane1"); // NOI18N
        jScrollPane1.setPreferredSize(new java.awt.Dimension(0, 0));

        jLabel1.setBackground(resourceMap.getColor("jLabel1.background")); // NOI18N
        jLabel1.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
        jLabel1.setText(resourceMap.getString("jLabel1.text")); // NOI18N
        jLabel1.setName("jLabel1"); // NOI18N
        jLabel1.addComponentListener(new java.awt.event.ComponentAdapter() {
            public void componentResized(java.awt.event.ComponentEvent evt) {
                jLabel1ComponentResized(evt);
            }
        });
        jScrollPane1.setViewportView(jLabel1);

        javax.swing.GroupLayout mainPanelLayout = new javax.swing.GroupLayout(mainPanel);
        mainPanel.setLayout(mainPanelLayout);
        mainPanelLayout.setHorizontalGroup(
            mainPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addComponent(jScrollPane1, javax.swing.GroupLayout.DEFAULT_SIZE, 758, Short.MAX_VALUE)
        );
        mainPanelLayout.setVerticalGroup(
            mainPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addComponent(jScrollPane1, javax.swing.GroupLayout.Alignment.TRAILING, javax.swing.GroupLayout.DEFAULT_SIZE, 522, Short.MAX_VALUE)
        );

        menuBar.setBackground(resourceMap.getColor("menuBar.background")); // NOI18N
        menuBar.setName("menuBar"); // NOI18N

        javax.swing.ActionMap actionMap = org.jdesktop.application.Application.getInstance(rautorviewer.RautorViewerApp.class).getContext().getActionMap(RautorViewerView.class, this);
        fileMenu.setAction(actionMap.get("PickSession")); // NOI18N
        fileMenu.setBackground(resourceMap.getColor("fileMenu.background")); // NOI18N
        fileMenu.setForeground(resourceMap.getColor("fileMenu.foreground")); // NOI18N
        fileMenu.setText(resourceMap.getString("fileMenu.text")); // NOI18N
        fileMenu.setName("fileMenu"); // NOI18N

        jMenuItem8.setAction(actionMap.get("PickSession")); // NOI18N
        jMenuItem8.setIcon(resourceMap.getIcon("jMenuItem8.icon")); // NOI18N
        jMenuItem8.setText(resourceMap.getString("jMenuItem8.text")); // NOI18N
        jMenuItem8.setActionCommand(resourceMap.getString("jMenuItem8.actionCommand")); // NOI18N
        jMenuItem8.setName("jMenuItem8"); // NOI18N
        fileMenu.add(jMenuItem8);

        jMenuItem3.setAction(actionMap.get("ReloadSession")); // NOI18N
        jMenuItem3.setIcon(resourceMap.getIcon("jMenuItem3.icon")); // NOI18N
        jMenuItem3.setText(resourceMap.getString("jMenuItem3.text")); // NOI18N
        jMenuItem3.setName("jMenuItem3"); // NOI18N
        fileMenu.add(jMenuItem3);

        exitMenuItem.setAction(actionMap.get("quit")); // NOI18N
        exitMenuItem.setIcon(resourceMap.getIcon("exitMenuItem.icon")); // NOI18N
        exitMenuItem.setName("exitMenuItem"); // NOI18N
        fileMenu.add(exitMenuItem);

        menuBar.add(fileMenu);

        jMenu1.setBackground(resourceMap.getColor("jMenu1.background")); // NOI18N
        jMenu1.setForeground(resourceMap.getColor("jMenu1.foreground")); // NOI18N
        jMenu1.setIcon(resourceMap.getIcon("jMenu1.icon")); // NOI18N
        jMenu1.setText(resourceMap.getString("jMenu1.text")); // NOI18N
        jMenu1.setName("jMenu1"); // NOI18N

        jMenuItem4.setAction(actionMap.get("ViewFullKeyboardLog")); // NOI18N
        jMenuItem4.setIcon(resourceMap.getIcon("jMenuItem4.icon")); // NOI18N
        jMenuItem4.setText(resourceMap.getString("jMenuItem4.text")); // NOI18N
        jMenuItem4.setActionCommand(resourceMap.getString("jMenuItem4.actionCommand")); // NOI18N
        jMenuItem4.setName("jMenuItem4"); // NOI18N
        jMenu1.add(jMenuItem4);

        jMenuItem5.setAction(actionMap.get("ViewSessionLog")); // NOI18N
        jMenuItem5.setIcon(resourceMap.getIcon("jMenuItem5.icon")); // NOI18N
        jMenuItem5.setText(resourceMap.getString("jMenuItem5.text")); // NOI18N
        jMenuItem5.setActionCommand(resourceMap.getString("jMenuItem5.actionCommand")); // NOI18N
        jMenuItem5.setName("jMenuItem5"); // NOI18N
        jMenu1.add(jMenuItem5);

        jSeparator1.setName("jSeparator1"); // NOI18N
        jMenu1.add(jSeparator1);

        jMenuItem2.setAction(actionMap.get("ViewCurrentScreenContents")); // NOI18N
        jMenuItem2.setIcon(resourceMap.getIcon("jMenuItem2.icon")); // NOI18N
        jMenuItem2.setText(resourceMap.getString("jMenuItem2.text")); // NOI18N
        jMenuItem2.setName("jMenuItem2"); // NOI18N
        jMenu1.add(jMenuItem2);

        menuBar.add(jMenu1);

        jMenu2.setBackground(resourceMap.getColor("jMenu2.background")); // NOI18N
        jMenu2.setForeground(resourceMap.getColor("jMenu2.foreground")); // NOI18N
        jMenu2.setText(resourceMap.getString("jMenu2.text")); // NOI18N
        jMenu2.setName("jMenu2"); // NOI18N

        FitImagesMenuItem.setAccelerator(javax.swing.KeyStroke.getKeyStroke(java.awt.event.KeyEvent.VK_Z, java.awt.event.InputEvent.CTRL_MASK));
        FitImagesMenuItem.setText(resourceMap.getString("FitImagesMenuItem.text")); // NOI18N
        FitImagesMenuItem.setName("FitImagesMenuItem"); // NOI18N
        FitImagesMenuItem.addChangeListener(new javax.swing.event.ChangeListener() {
            public void stateChanged(javax.swing.event.ChangeEvent evt) {
                FitImagesMenuItemStateChanged(evt);
            }
        });
        jMenu2.add(FitImagesMenuItem);

        AspectRatioMenuItem.setText(resourceMap.getString("AspectRatioMenuItem.text")); // NOI18N
        AspectRatioMenuItem.setName("AspectRatioMenuItem"); // NOI18N
        AspectRatioMenuItem.addChangeListener(new javax.swing.event.ChangeListener() {
            public void stateChanged(javax.swing.event.ChangeEvent evt) {
                AspectRatioMenuItemStateChanged(evt);
            }
        });
        jMenu2.add(AspectRatioMenuItem);

        jMenu3.setText(resourceMap.getString("jMenu3.text")); // NOI18N
        jMenu3.setName("jMenu3"); // NOI18N

        buttonGroup1.add(jRadioButtonMenuItem3);
        jRadioButtonMenuItem3.setText(resourceMap.getString("jRadioButtonMenuItem3.text")); // NOI18N
        jRadioButtonMenuItem3.setName("jRadioButtonMenuItem3"); // NOI18N
        jRadioButtonMenuItem3.addChangeListener(new javax.swing.event.ChangeListener() {
            public void stateChanged(javax.swing.event.ChangeEvent evt) {
                jRadioButtonMenuItem3StateChanged(evt);
            }
        });
        jMenu3.add(jRadioButtonMenuItem3);

        buttonGroup1.add(jRadioButtonMenuItem1);
        jRadioButtonMenuItem1.setSelected(true);
        jRadioButtonMenuItem1.setText(resourceMap.getString("jRadioButtonMenuItem1.text")); // NOI18N
        jRadioButtonMenuItem1.setName("jRadioButtonMenuItem1"); // NOI18N
        jRadioButtonMenuItem1.addChangeListener(new javax.swing.event.ChangeListener() {
            public void stateChanged(javax.swing.event.ChangeEvent evt) {
                jRadioButtonMenuItem1StateChanged(evt);
            }
        });
        jMenu3.add(jRadioButtonMenuItem1);

        buttonGroup1.add(jRadioButtonMenuItem2);
        jRadioButtonMenuItem2.setText(resourceMap.getString("jRadioButtonMenuItem2.text")); // NOI18N
        jRadioButtonMenuItem2.setName("jRadioButtonMenuItem2"); // NOI18N
        jRadioButtonMenuItem2.addChangeListener(new javax.swing.event.ChangeListener() {
            public void stateChanged(javax.swing.event.ChangeEvent evt) {
                jRadioButtonMenuItem2StateChanged(evt);
            }
        });
        jMenu3.add(jRadioButtonMenuItem2);

        jMenu2.add(jMenu3);

        menuBar.add(jMenu2);

        jMenu4.setBackground(resourceMap.getColor("jMenu4.background")); // NOI18N
        jMenu4.setForeground(resourceMap.getColor("jMenu4.foreground")); // NOI18N
        jMenu4.setText(resourceMap.getString("jMenu4.text")); // NOI18N
        jMenu4.setName("jMenu4"); // NOI18N

        SearchMenuItem.setAction(actionMap.get("OpenSearchTextBox")); // NOI18N
        SearchMenuItem.setAccelerator(javax.swing.KeyStroke.getKeyStroke(java.awt.event.KeyEvent.VK_F, java.awt.event.InputEvent.CTRL_MASK));
        SearchMenuItem.setText(resourceMap.getString("SearchMenuItem.text")); // NOI18N
        SearchMenuItem.setName("SearchMenuItem"); // NOI18N
        jMenu4.add(SearchMenuItem);

        jMenuItem6.setAction(actionMap.get("lookforNext")); // NOI18N
        jMenuItem6.setAccelerator(javax.swing.KeyStroke.getKeyStroke(java.awt.event.KeyEvent.VK_N, java.awt.event.InputEvent.CTRL_MASK));
        jMenuItem6.setText(resourceMap.getString("jMenuItem6.text")); // NOI18N
        jMenuItem6.setName("jMenuItem6"); // NOI18N
        jMenuItem6.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                jMenuItem6ActionPerformed(evt);
            }
        });
        jMenu4.add(jMenuItem6);

        menuBar.add(jMenu4);

        helpMenu.setBackground(resourceMap.getColor("helpMenu.background")); // NOI18N
        helpMenu.setForeground(resourceMap.getColor("helpMenu.foreground")); // NOI18N
        helpMenu.setText(resourceMap.getString("helpMenu.text")); // NOI18N
        helpMenu.setName("helpMenu"); // NOI18N

        aboutMenuItem.setAction(actionMap.get("showAboutBox")); // NOI18N
        aboutMenuItem.setAccelerator(javax.swing.KeyStroke.getKeyStroke(java.awt.event.KeyEvent.VK_F1, 0));
        aboutMenuItem.setIcon(resourceMap.getIcon("aboutMenuItem.icon")); // NOI18N
        aboutMenuItem.setText(resourceMap.getString("aboutMenuItem.text")); // NOI18N
        aboutMenuItem.setName("aboutMenuItem"); // NOI18N
        helpMenu.add(aboutMenuItem);

        menuBar.add(helpMenu);

        statusPanel.setBackground(resourceMap.getColor("statusPanel.background")); // NOI18N
        statusPanel.setName("statusPanel"); // NOI18N

        statusMessageLabel.setBackground(resourceMap.getColor("statusMessageLabel.background")); // NOI18N
        statusMessageLabel.setHorizontalAlignment(javax.swing.SwingConstants.LEFT);
        statusMessageLabel.setHorizontalTextPosition(javax.swing.SwingConstants.LEFT);
        statusMessageLabel.setName("statusMessageLabel"); // NOI18N

        statusAnimationLabel.setHorizontalAlignment(javax.swing.SwingConstants.LEFT);
        statusAnimationLabel.setName("statusAnimationLabel"); // NOI18N

        progressBar.setName("progressBar"); // NOI18N

        VideoSlider.setBackground(resourceMap.getColor("VideoSlider.background")); // NOI18N
        VideoSlider.setMaximum(0);
        VideoSlider.setMinimumSize(new java.awt.Dimension(16, 25));
        VideoSlider.setName("VideoSlider"); // NOI18N
        VideoSlider.addChangeListener(new javax.swing.event.ChangeListener() {
            public void stateChanged(javax.swing.event.ChangeEvent evt) {
                VideoSliderStateChanged(evt);
            }
        });
        VideoSlider.addMouseMotionListener(new java.awt.event.MouseMotionAdapter() {
            public void mouseDragged(java.awt.event.MouseEvent evt) {
                VideoSliderMouseDragged(evt);
            }
        });

        StopReplayButton.setAction(actionMap.get("StopReplay")); // NOI18N
        StopReplayButton.setIcon(resourceMap.getIcon("StopReplayButton.icon")); // NOI18N
        StopReplayButton.setName("StopReplayButton"); // NOI18N

        jSpinner1.setModel(new javax.swing.SpinnerNumberModel(250, 0, 2000, 10));
        jSpinner1.setName("jSpinner1"); // NOI18N
        jSpinner1.setRequestFocusEnabled(false);

        StartReplayButton.setAction(actionMap.get("Replay")); // NOI18N
        StartReplayButton.setIcon(resourceMap.getIcon("StartReplayButton.icon")); // NOI18N
        StartReplayButton.setBorderPainted(false);
        StartReplayButton.setName("StartReplayButton"); // NOI18N

        FollowButton.setAction(actionMap.get("FollowUser")); // NOI18N
        FollowButton.setIcon(resourceMap.getIcon("FollowButton.icon")); // NOI18N
        FollowButton.setToolTipText(resourceMap.getString("FollowButton.toolTipText")); // NOI18N
        FollowButton.setBorderPainted(false);
        FollowButton.setName("FollowButton"); // NOI18N

        KeyLog.setBackground(resourceMap.getColor("KeyLog.background")); // NOI18N
        KeyLog.setEditable(false);
        KeyLog.setForeground(resourceMap.getColor("KeyLog.foreground")); // NOI18N
        KeyLog.setText(resourceMap.getString("KeyLog.text")); // NOI18N
        KeyLog.setToolTipText(resourceMap.getString("KeyLog.toolTipText")); // NOI18N
        KeyLog.setBorder(new javax.swing.border.LineBorder(resourceMap.getColor("KeyLog.border.lineColor"), 1, true)); // NOI18N
        KeyLog.setName("KeyLog"); // NOI18N

        jSeparator2.setName("jSeparator2"); // NOI18N

        javax.swing.GroupLayout statusPanelLayout = new javax.swing.GroupLayout(statusPanel);
        statusPanel.setLayout(statusPanelLayout);
        statusPanelLayout.setHorizontalGroup(
            statusPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, statusPanelLayout.createSequentialGroup()
                .addContainerGap()
                .addGroup(statusPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.TRAILING)
                    .addComponent(KeyLog, javax.swing.GroupLayout.DEFAULT_SIZE, 740, Short.MAX_VALUE)
                    .addGroup(statusPanelLayout.createSequentialGroup()
                        .addGroup(statusPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                            .addGroup(statusPanelLayout.createSequentialGroup()
                                .addComponent(statusMessageLabel, javax.swing.GroupLayout.DEFAULT_SIZE, 610, Short.MAX_VALUE)
                                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                                .addComponent(progressBar, javax.swing.GroupLayout.PREFERRED_SIZE, 89, javax.swing.GroupLayout.PREFERRED_SIZE))
                            .addGroup(statusPanelLayout.createSequentialGroup()
                                .addComponent(StartReplayButton, javax.swing.GroupLayout.PREFERRED_SIZE, 33, javax.swing.GroupLayout.PREFERRED_SIZE)
                                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                                .addComponent(StopReplayButton, javax.swing.GroupLayout.PREFERRED_SIZE, 33, javax.swing.GroupLayout.PREFERRED_SIZE)
                                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                                .addComponent(jSpinner1, javax.swing.GroupLayout.PREFERRED_SIZE, 51, javax.swing.GroupLayout.PREFERRED_SIZE)
                                .addGap(18, 18, 18)
                                .addComponent(VideoSlider, javax.swing.GroupLayout.DEFAULT_SIZE, 556, Short.MAX_VALUE)))
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addGroup(statusPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.TRAILING, false)
                            .addGroup(statusPanelLayout.createSequentialGroup()
                                .addGap(10, 10, 10)
                                .addComponent(statusAnimationLabel, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
                            .addComponent(FollowButton, javax.swing.GroupLayout.PREFERRED_SIZE, 31, javax.swing.GroupLayout.PREFERRED_SIZE))
                        .addGap(0, 0, 0)))
                .addContainerGap())
            .addGroup(statusPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                .addComponent(jSeparator2, javax.swing.GroupLayout.Alignment.TRAILING, javax.swing.GroupLayout.DEFAULT_SIZE, 760, Short.MAX_VALUE))
        );
        statusPanelLayout.setVerticalGroup(
            statusPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(statusPanelLayout.createSequentialGroup()
                .addComponent(KeyLog, javax.swing.GroupLayout.PREFERRED_SIZE, 19, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(0, 0, 0)
                .addGroup(statusPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addComponent(VideoSlider, javax.swing.GroupLayout.DEFAULT_SIZE, 33, Short.MAX_VALUE)
                    .addComponent(FollowButton, javax.swing.GroupLayout.PREFERRED_SIZE, 33, Short.MAX_VALUE)
                    .addComponent(StartReplayButton, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                    .addComponent(StopReplayButton, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                    .addComponent(jSpinner1, javax.swing.GroupLayout.DEFAULT_SIZE, 33, Short.MAX_VALUE))
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addGroup(statusPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addComponent(statusAnimationLabel, javax.swing.GroupLayout.DEFAULT_SIZE, 19, Short.MAX_VALUE)
                    .addComponent(progressBar, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addComponent(statusMessageLabel, javax.swing.GroupLayout.DEFAULT_SIZE, 19, Short.MAX_VALUE)))
            .addGroup(statusPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, statusPanelLayout.createSequentialGroup()
                    .addContainerGap(55, Short.MAX_VALUE)
                    .addComponent(jSeparator2, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addGap(20, 20, 20)))
        );

        jButton1.setText(resourceMap.getString("jButton1.text")); // NOI18N
        jButton1.setName("jButton1"); // NOI18N

        jPanel1.setName("jPanel1"); // NOI18N

        javax.swing.GroupLayout jPanel1Layout = new javax.swing.GroupLayout(jPanel1);
        jPanel1.setLayout(jPanel1Layout);
        jPanel1Layout.setHorizontalGroup(
            jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGap(0, 100, Short.MAX_VALUE)
        );
        jPanel1Layout.setVerticalGroup(
            jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGap(0, 132, Short.MAX_VALUE)
        );

        setComponent(mainPanel);
        setMenuBar(menuBar);
        setStatusBar(statusPanel);
    }// </editor-fold>//GEN-END:initComponents

    private void VideoSliderStateChanged(javax.swing.event.ChangeEvent evt) {//GEN-FIRST:event_VideoSliderStateChanged
        JSlider source = (JSlider)evt.getSource();
        if ( Files == null) return;
        if (VideoLast<=0) return;
        if (!source.getValueIsAdjusting()) {
            int val = (int)source.getValue();
            VideoIndex=val;
            DispImage(val);
        }

    }//GEN-LAST:event_VideoSliderStateChanged

    private void VideoSliderMouseDragged(java.awt.event.MouseEvent evt) {//GEN-FIRST:event_VideoSliderMouseDragged
        JSlider source = (JSlider)evt.getSource();        
            int val = (int)source.getValue();
            if (Files == null) return;
            if (VideoLast<=0) return;
            VideoIndex=val;
            DispImage(val);
    }//GEN-LAST:event_VideoSliderMouseDragged

    private void FitImagesMenuItemStateChanged(javax.swing.event.ChangeEvent evt) {//GEN-FIRST:event_FitImagesMenuItemStateChanged
            JCheckBoxMenuItem source = (JCheckBoxMenuItem)evt.getSource();
            FitImages = source.isSelected();
            DispImage(VideoIndex);
    }//GEN-LAST:event_FitImagesMenuItemStateChanged

    private void AspectRatioMenuItemStateChanged(javax.swing.event.ChangeEvent evt) {//GEN-FIRST:event_AspectRatioMenuItemStateChanged
            JCheckBoxMenuItem source = (JCheckBoxMenuItem)evt.getSource();
            AspectFixed = source.isSelected();
            DispImage(VideoIndex);
    }//GEN-LAST:event_AspectRatioMenuItemStateChanged

    private void jLabel1ComponentResized(java.awt.event.ComponentEvent evt) {//GEN-FIRST:event_jLabel1ComponentResized
        DispImage(VideoIndex);
    }//GEN-LAST:event_jLabel1ComponentResized

    private void jRadioButtonMenuItem1StateChanged(javax.swing.event.ChangeEvent evt) {//GEN-FIRST:event_jRadioButtonMenuItem1StateChanged
       JRadioButtonMenuItem source = (JRadioButtonMenuItem)evt.getSource();
       if ( source.isSelected())
            ZoomAlgorithm=2;
       DispImage(VideoIndex);
    }//GEN-LAST:event_jRadioButtonMenuItem1StateChanged

    private void jRadioButtonMenuItem3StateChanged(javax.swing.event.ChangeEvent evt) {//GEN-FIRST:event_jRadioButtonMenuItem3StateChanged
       JRadioButtonMenuItem source = (JRadioButtonMenuItem)evt.getSource();
       if ( source.isSelected())
            ZoomAlgorithm=1;
       DispImage(VideoIndex);
    }//GEN-LAST:event_jRadioButtonMenuItem3StateChanged

    private void jRadioButtonMenuItem2StateChanged(javax.swing.event.ChangeEvent evt) {//GEN-FIRST:event_jRadioButtonMenuItem2StateChanged
       JRadioButtonMenuItem source = (JRadioButtonMenuItem)evt.getSource();
       if ( source.isSelected())
            ZoomAlgorithm=3;
       DispImage(VideoIndex);
    }//GEN-LAST:event_jRadioButtonMenuItem2StateChanged

    private void jMenuItem6ActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_jMenuItem6ActionPerformed
        // TODO add your handling code here:
    }//GEN-LAST:event_jMenuItem6ActionPerformed


    /*
     *
     * Most of the display work takes place here
     *
     *
     */
    public void DispImage(int Index){        
       
        if ( Files == null ){       
            return;
        }

        if ( Index > VideoLast) {
            statusMessageLabel.setText("Image Not created yet ");
            return;
        }
        
        if ( FitImages==false) {
                ShowUnscaledImage(Index);
        }else { // Scaled Image
                ShowScaledImage(Index);                                        
        }

        // CurrentScreenContents=ReadScreenContents(Index); /* needed later on */
        ViewCurrentKeyboardLog();
    }

// ***********************************

void ShowScaledImage(int val){        
    ImageIcon myimage=null;

        Image scaled=null,unscaled=null;
        if ( SessionIsRemote){
            /*
            String FriendlyName=VFSUtils.getFriendlyName(Files[val]);
            statusMessageLabel.setText("Scaling:" + FriendlyName );
            try {
                FileObject RemoteFile=VFSUtils.createFileObject(Files[val]);
                InputStream is=VFSUtils.getInputStream(RemoteFile);
                unscaled = ImageIO.read(is);
            } catch ( Exception e){
                statusMessageLabel.setText(e.getLocalizedMessage()  );
                return;
            }
             */
        } else {
            statusMessageLabel.setText("Scaling:" +Files[val]);
            try {
                unscaled=ImageIO.read(new File(FullPath+"/"+Files[val]));
            } catch (Exception e) {
                statusMessageLabel.setText(e.getLocalizedMessage() + " " +  Files[val] );
               return;
            }
        }

    // Ok we got the image now;
        int width=unscaled.getWidth(null);
        int height= unscaled.getHeight(null);
        float aspect=width/height;
        if (AspectFixed==true){
            width=jScrollPane1.getWidth()-30;
            height=(int)aspect*width;
        }else{
            width=jScrollPane1.getWidth()-10;
            height=jScrollPane1.getHeight()-10;
        }
        switch(ZoomAlgorithm){
            case 1:scaled =unscaled.getScaledInstance(width, height, Image.SCALE_FAST);
                    break;
//                    case 2: scaled =unscaled.getScaledInstance(width, height, Image.SCALE_DEFAULT);
//                            break;
            case 3: scaled =unscaled.getScaledInstance(width, height, Image.SCALE_SMOOTH);
                    break;
            default: scaled =unscaled.getScaledInstance(width, height, Image.SCALE_DEFAULT);
                    break;
        }

        if (scaled ==null) {
            statusMessageLabel.setText("Could not scale:"+Files[val]);
            return;
        }

        jLabel1.setIcon(new ImageIcon(scaled));
//        if ( SessionIsRemote) {
//              String FriendlyName=VFSUtils.getFriendlyName(Files[val]);
//              statusMessageLabel.setText(FriendlyName);
//        } else{
                statusMessageLabel.setText(Files[val]);    
//        }
}
    

// *************************************

void ShowUnscaledImage(int val){
ImageIcon myimage=null;


    statusMessageLabel.setText("trying to show image");

 if (SessionIsRemote){
     /*
        String FriendlyName=VFSUtils.getFriendlyName(Files[val]);
        try {
            FileObject RemoteFile=VFSUtils.createFileObject(Files[val]);
            InputStream is=VFSUtils.getInputStream(RemoteFile);
            Image tmpimage = ImageIO.read(is);
            myimage=new ImageIcon(tmpimage);
        } catch ( Exception e){
            statusMessageLabel.setText(e.getLocalizedMessage()  );
            return;
        }
*/
    }  else {
        try {
                myimage=new ImageIcon(FullPath+"/"+Files[val]);
            } catch ( Exception e) {
                statusMessageLabel.setText(e.getLocalizedMessage() + " " +  Files[val]);
                return;
            }
    }
    if ( myimage!=null) {
        jLabel1.setIcon(myimage);
        statusMessageLabel.setText(Files[val]);
    }
}

// **************************************

    @Action
    public void PickSession() {
        File Sessiondir;

         JFrame frame = new JFrame();

        SecurityManager backup = System.getSecurityManager();
        System.setSecurityManager(null);
        SessionIsRemote=false;
        File CWD = new File("/Audit");        
        messageTimer.setRepeats(true);
        JFileChooser fc = new JFileChooser();        
        fc.setFileSelectionMode(JFileChooser.FILES_AND_DIRECTORIES);
        fc.setCurrentDirectory(CWD);
        fc.setDialogTitle(AppName+" Choose Only the session's SubDirectory");
        if ( LastSessiondir != null){
            fc.setCurrentDirectory(LastSessiondir);
        }
        int returnVal=-1;
        try {
            returnVal = fc.showOpenDialog(frame);
        } catch ( Exception e) {
            statusMessageLabel.setText(e.getLocalizedMessage());
        }
       System.setSecurityManager(backup);
       if (returnVal != JFileChooser.APPROVE_OPTION) {
            statusMessageLabel.setText("Open command cancelled by user.");
            busyIconTimer.stop();
            statusAnimationLabel.setIcon(idleIcon);
            return;
        }

        statusMessageLabel.setText("Reading files");
        Sessiondir = fc.getSelectedFile();            
        LastSessiondir= new File (Sessiondir.getPath());
        VideoSlider.setEnabled(false);
        StartReplayButton.setEnabled(false);

        if ( FollowToggled==true){
            FollowButton.doClick();
        }
        busyIconTimer.start();
        doWork(LastSessiondir);
        busyIconTimer.stop();
        statusAnimationLabel.setIcon(idleIcon);
    }
/*
@Action
public void ChooseFTPSession() {
        final FileObject Sessiondir ;
        final String FName;
        final File LocalSessionDir ;
//      SecurityManager backup = System.getSecurityManager();
        System.setSecurityManager(null);        
        messageTimer.setRepeats(true);
       
        // create a file chooser that will be something to look into
        final VFSJFileChooser fileChooser = new VFSJFileChooser();

        // configure the file dialog
        fileChooser.setAccessory(new DefaultAccessoriesPanel(fileChooser));
        fileChooser.setFileHidingEnabled(false);
        fileChooser.setMultiSelectionEnabled(false);
        fileChooser.setFileSelectionMode(VFSJFileChooser.SELECTION_MODE.FILES_AND_DIRECTORIES);
        if ( LastFtpSessiondir != null){
            fileChooser.setCurrentDirectory(LastFtpSessiondir);
        }
        // show the file dialog

        fileChooser.setDialogTitle(AppName+" Choose Only the session's SubDirectory");
        VFSJFileChooser.RETURN_TYPE answer = fileChooser.showOpenDialog(null);

    // check if a file was selected
    if (answer == VFSJFileChooser.RETURN_TYPE.APPROVE)
    {
        // remove authentication credentials from the file path
        // final String safeName =   VFSUtils.getFriendlyName(fileChooser.getSelectedFile().toString());

             FName =   fileChooser.getSelectedFile().toString();
             statusMessageLabel.setText("Reading files");             
             Sessiondir =   fileChooser.getSelectedFile();
             LastFtpSessiondir = Sessiondir;
        } else {
            statusMessageLabel.setText("Open command cancelled by user.");
            busyIconTimer.stop(); 
            statusAnimationLabel.setIcon(idleIcon);
            LastFtpSessiondir = null;
            return;
        }
        VideoSlider.setEnabled(false);
        StartReplayButton.setEnabled(false);

        if ( FollowToggled==true){
            FollowButton.doClick();
        }
        
        busyIconTimer.start();
        if (  ! Sessiondir.toString().contains("file://") ){
            SessionIsRemote=true;
            doFtpWork(Sessiondir);
        } else {
            SessionIsRemote=false;
            String newFname;
            newFname=FName.substring(8);
            LocalSessionDir = new File(newFname );
            doWork(LocalSessionDir);
        }
        
        busyIconTimer.stop();
        statusAnimationLabel.setIcon(idleIcon);
}
*/


    @Action
    public void ReloadSession() {
        if ( SessionIsRemote) {
            /*
            if ( LastFtpSessiondir == null) {
                statusMessageLabel.setText("No session loaded");
                return;
            }
            busyIconTimer.start();
            doFtpWork(LastFtpSessiondir);
            busyIconTimer.stop();
            statusAnimationLabel.setIcon(idleIcon);
             */
        } else {
            if ( LastSessiondir == null) {
                statusMessageLabel.setText("No session loaded");
                return;
            }
            busyIconTimer.start();
            doWork(LastSessiondir);
            busyIconTimer.stop();
            statusAnimationLabel.setIcon(idleIcon);
        }
    }
/*

  public void doFtpWork(FileObject Sessiondir){                
        int i=0;       
        for ( FileObject filename : VFSUtils.getFiles(Sessiondir)){
            String Fname=filename.toString();            
            if (Fname.contains(".png") ||Fname.contains(".PNG")   ){
                i++;
            }
        }
 
        if (i<=0) {
            statusMessageLabel.setText("No PNG files found under "+FullPath);
            busyIconTimer.stop();
            statusAnimationLabel.setIcon(idleIcon);
            return;
        }
        Files=null;
        Files=new String[i];

       
        i=0;
        for ( FileObject filename : VFSUtils.getFiles(Sessiondir)){
            String Fname=filename.toString();
            if (Fname.contains(".png") ||Fname.contains(".PNG")   ){                
                Files[i]=Fname;
                i++;                
            }
        }

        VideoLast=Files.length-1;

        VideoSlider.setMaximum(VideoLast);
        VideoSlider.setEnabled(true);
        StartReplayButton.setEnabled(true);
        FollowButton.setEnabled(true);

        // Display the first or the last image ?
        int ind=0;
        if ( FollowToggled==true) { ind=VideoLast;  }
        FullPath=VFSUtils.getFriendlyName(Sessiondir.toString());
        FullFtpPath=Sessiondir.toString();
        JFrame mainFrame = RautorViewerApp.getApplication().getMainFrame();
        mainFrame.setTitle(AppName+" "+FullPath);
        VideoSlider.setValue(ind);
  }
 */

    public void doWork(File Sessiondir){
       String[] AllFiles;

        FullPath=Sessiondir.getPath();
        AllFiles=Sessiondir.list();
        
        int i=0;
        if ( AllFiles==null) {
                statusMessageLabel.setText("Please select the Directory above !");
                return;
        }
       
        Arrays.sort(AllFiles);
        for ( String filename : AllFiles){
            if (filename.contains(".png") ||filename.contains(".PNG")   )
                i++;
        }
        if (i<=0) {
            statusMessageLabel.setText("No PNG files found under "+FullPath);
            busyIconTimer.stop();
            statusAnimationLabel.setIcon(idleIcon);
            return;
        }
        Files=null;
        Files=new String[i];        
        

        i=0;
        for ( String filename : AllFiles ){
            if (filename.contains(".png") ||filename.contains(".PNG")   ){
                Files[i]=filename;
                i++;
                statusMessageLabel.setText(filename);
            }
        }
        VideoLast=Files.length-1;
        
        VideoSlider.setMaximum(VideoLast);
        VideoSlider.setEnabled(true);
        StartReplayButton.setEnabled(true);
        FollowButton.setEnabled(true);
               
        // Display the first or the last image ?
        int ind=0;
        if ( FollowToggled==true) { ind=VideoLast;  }

        JFrame mainFrame = RautorViewerApp.getApplication().getMainFrame();
        mainFrame.setTitle(AppName+" "+FullPath);
        VideoSlider.setValue(ind);

    }

/*
 *******************************************
 */

    @Action
    public void FollowUser()  {
        if ( SessionIsRemote) {
            /*
            if ( LastFtpSessiondir == null) {
                statusMessageLabel.setText("No session loaded");
                return;
            }
             */
        } else {
            if ( LastSessiondir == null) {
                statusMessageLabel.setText("No session loaded");
                return;
            }
        }
        if ( Replay==true){
            StopReplayButton.doClick();
        }
        if ( FollowToggled==false){
            FollowToggled=true;
            busyIconTimer.start();
        } else {
            FollowToggled=false;
            busyIconTimer.stop();
            statusAnimationLabel.setIcon(idleIcon);
        }        
    }

/*
 *******************************************
 */

    @Action
    public void StopReplay() {
        Replay=false;
        StartReplayButton.setEnabled(true);
        StopReplayButton.setEnabled(false);
        VideoSlider.setEnabled(true);
    }

    @Action
    public void Replay(){
        Replay=true;
        StartReplayButton.setEnabled(false);
        StopReplayButton.setEnabled(true);
        VideoSlider.setEnabled(false);
}


    // Variables declaration - do not modify//GEN-BEGIN:variables
    private javax.swing.JCheckBoxMenuItem AspectRatioMenuItem;
    private javax.swing.JCheckBoxMenuItem FitImagesMenuItem;
    private javax.swing.JToggleButton FollowButton;
    private javax.swing.JTextField KeyLog;
    private javax.swing.JMenuItem SearchMenuItem;
    private javax.swing.JButton StartReplayButton;
    private javax.swing.JButton StopReplayButton;
    private javax.swing.JSlider VideoSlider;
    private javax.swing.ButtonGroup buttonGroup1;
    private javax.swing.JButton jButton1;
    private javax.swing.JLabel jLabel1;
    private javax.swing.JMenu jMenu1;
    private javax.swing.JMenu jMenu2;
    private javax.swing.JMenu jMenu3;
    private javax.swing.JMenu jMenu4;
    private javax.swing.JMenuItem jMenuItem2;
    private javax.swing.JMenuItem jMenuItem3;
    private javax.swing.JMenuItem jMenuItem4;
    private javax.swing.JMenuItem jMenuItem5;
    private javax.swing.JMenuItem jMenuItem6;
    private javax.swing.JMenuItem jMenuItem8;
    private javax.swing.JPanel jPanel1;
    private javax.swing.JRadioButtonMenuItem jRadioButtonMenuItem1;
    private javax.swing.JRadioButtonMenuItem jRadioButtonMenuItem2;
    private javax.swing.JRadioButtonMenuItem jRadioButtonMenuItem3;
    private javax.swing.JScrollPane jScrollPane1;
    private javax.swing.JSeparator jSeparator1;
    private javax.swing.JSeparator jSeparator2;
    private javax.swing.JSpinner jSpinner1;
    private javax.swing.JPanel mainPanel;
    private javax.swing.JMenuBar menuBar;
    private javax.swing.JProgressBar progressBar;
    private javax.swing.JLabel statusAnimationLabel;
    private javax.swing.JLabel statusMessageLabel;
    private javax.swing.JPanel statusPanel;
    // End of variables declaration//GEN-END:variables

    private final Timer messageTimer;
    private final Timer busyIconTimer;
    private final Icon idleIcon;
    private final Icon[] busyIcons = new Icon[15];
    private int busyIconIndex = 0;

    private JDialog aboutBox;
    
/*
 *******************************************
 */
    @Action
    public void ViewFullKeyboardLog() {
        BufferedReader FKL;
        String FullKeyboardLog="";

        if ( Files == null ) {
            statusMessageLabel.setText("No session loaded");
            return;
        }

        if ( SessionIsRemote){
            /*

            try {
                FileObject RemoteFile=VFSUtils.createFileObject(FullFtpPath+"/KeyBoard_Log.txt");
                FileContent Klog=RemoteFile.getContent();
                FKL=new BufferedReader(new InputStreamReader(Klog.getInputStream(),localCharset));    
                String line;
                do {
                    line=FKL.readLine() ;
                    if ( line != null ) {
                        FullKeyboardLog=FullKeyboardLog + line +"\n";
                    }
                } while ( line != null);
            } catch ( Exception e){
                statusMessageLabel.setText(e.getLocalizedMessage());
                return;
            }
             */
        } else {
            try {
                FKL=new BufferedReader(new FileReader(FullPath+"\\KeyBoard_Log.txt"));
                String line="";
                while (line !=null){
                   line=FKL.readLine();
                   if ( line !=null) {
                    FullKeyboardLog=FullKeyboardLog + line +"\n";
                   }
                }
           }catch (IOException e) {
                statusMessageLabel.setText(e.getLocalizedMessage());
                return;
                }
        }
        showEditorBox("Full Keyboard Log",FullKeyboardLog,0,0);
    }
/* *******************************************  */

    @Action
    public void ViewSessionLog() {
        BufferedReader FKL;
        String SessionLog="";

        if ( Files==null){
            statusMessageLabel.setText("No session loaded");
            return;
        }
        if ( SessionIsRemote){
            /*
            try {
                FileObject RemoteFile=VFSUtils.createFileObject(FullFtpPath+"/Session_Log.txt");
                FileContent Klog=RemoteFile.getContent();
                FKL=new BufferedReader(new InputStreamReader(Klog.getInputStream(),localCharset));
                String line;
                do {
                    line=FKL.readLine() ;
                    if ( line != null ) {
                        SessionLog=SessionLog + line +"\n";
                    }
                } while ( line != null);
            } catch ( Exception e){
                statusMessageLabel.setText(e.getLocalizedMessage());
                return;
            }
             */
        } else {
            try {
                FKL=new BufferedReader(new FileReader(FullPath+"\\Session_Log.txt"));
                String line="";
                while (line != null){
                    line=FKL.readLine();
                    if (line != null); {
                        SessionLog=SessionLog + line +"\n";
                    }
                }
            }catch (IOException e) {
                statusMessageLabel.setText(e.getLocalizedMessage());
                return;
            }
        }
        showEditorBox("Full Session Log",SessionLog,0,0);
    }

/*  ******************************************* */
    @Action
    public void ViewCurrentKeyboardLog() {
        BufferedReader FKL;
        String KeyboardLog="";

        KeyLog.setText("");
        if (Files==null) {
            statusMessageLabel.setText("No session loaded");
            return;
        }
        int i=VideoIndex;
        int Fl=Files[i].length();
        String Pfname=Files[i].substring(0,Fl-4); // remove .png;
        String Kfname=Pfname+"-KeyboardLog.txt";

        if ( SessionIsRemote){
                /*
            try {
                FileObject RemoteFile=VFSUtils.createFileObject(Kfname);
                FileContent Klog=RemoteFile.getContent();
                FKL=new BufferedReader(new InputStreamReader(Klog.getInputStream(),localCharset));
                String line;
                do {
                    line=FKL.readLine() ;
                    if ( line != null ) {
                       if ( line.length()>16)
                            KeyboardLog=KeyboardLog + line.substring(16);
                    }
                } while ( line != null);
            } catch ( Exception e){
                statusMessageLabel.setText(e.getLocalizedMessage());
                return;
            }
            */
        } else {
            try {
                FKL=new BufferedReader(new FileReader(FullPath+"\\"+ Kfname));
                String line="";
                while (line != null){
                    line=FKL.readLine();
                    if ( line != null ) {
                        if ( line.length()>16)
                            KeyboardLog=KeyboardLog + line.substring(16);
                    }
                }
            }catch (IOException e) {
                statusMessageLabel.setText(e.getLocalizedMessage());
                return;
                }
        }
        KeyLog.setText(KeyboardLog);
    }


    /* ******************************************** */
@Action
public void ViewCurrentScreenContents() {

        CurrentScreenContents=ReadScreenContents(VideoIndex);
        if (CurrentScreenContents==null){
            statusMessageLabel.setText("Weird: No screen contents for this screen");
            return;
        }
       if ( CurrentScreenContents.length()!=0) {
            showEditorBox("Current Screen Contents",CurrentScreenContents,ScreenContentsHighlightStart,ScreenContentsHighlightEnd);
       } else {
            statusMessageLabel.setText("Weird: No screen contents for this screen");
       }
}

/* ********************************************
            Read Screen Contents 
   ******************************************** */
public String ReadScreenContents(int i) {
        BufferedReader FKL;
        
        if  (Files==null)  {
            statusMessageLabel.setText("No session loaded");
            return null;
        }
                
        int Fl=Files[i].length();
        String Pfname=Files[i].substring(0,Fl-4); // remove .png
        String fname=Pfname+"-ScreenContents.txt";
        statusMessageLabel.setText("Please Wait:Reading Screen Contents from:"+Files[i]);
        StringBuilder Contents = new StringBuilder();
      if ( SessionIsRemote){
          /*
          try {

              FileObject RemoteFile=VFSUtils.createFileObject(fname);
              InputStream is=VFSUtils.getInputStream(RemoteFile);
              FKL=new BufferedReader(new InputStreamReader(is,localCharset));                 
                String line;
                do {
                    line=FKL.readLine();
                    if ( line !=null ){
                        Contents=Contents+ line +"\n";
                    }
                } while (line !=null);         
        }catch (IOException e) {
                statusMessageLabel.setText(e.getLocalizedMessage());
                return null;
        }
               */

      }else { // session is local
        try {         
            FKL=new BufferedReader(new InputStreamReader(new FileInputStream(FullPath+"\\"+fname),localCharset));
             String friendlyname=FullPath+"\\"+fname;
            statusMessageLabel.setText("Reading:"+friendlyname);
            String line="";
            while (line !=null){
                line=FKL.readLine();
                if ( line != null) {
                    Contents.append(line);
                    Contents.append("\n");
                }
            }
        }catch (IOException e) {
                statusMessageLabel.setText(e.getLocalizedMessage()+fname);
                return null;
        }
      }
      return Contents.toString();
}


    /*
     **********************************
          Show the Find Text box
     **********************************
     */
    @Action
    public void OpenSearchTextBox() {
    JDialog SearchtextBoxDialog;

        StopReplayButton.doClick();
        JFrame mainFrame = RautorViewerApp.getApplication().getMainFrame();
        SearchtextBoxDialog =new SearchTextBox(mainFrame,true);
        SearchtextBoxDialog.setLocationRelativeTo(mainFrame);
        SearchtextBoxDialog.setTitle(AppName + "  Look for Text");
        RautorViewerApp.getApplication().show(SearchtextBoxDialog);

        SearchText=SearchTextBox.getTextField();
        if ( SearchText != null) {
            lookfor(SearchText);
        }
    }
        /* *********************************************************** */
@Action
public void lookforNext(){
    VideoIndex++;
    VideoSlider.setValue(VideoIndex);
    SearchText=SearchTextBox.getTextField();
     if ( SearchText != null) {
            lookfor(SearchText);
        }
}
/* *********************************************************** */
    public void lookfor(String SearchText){
        if (VideoLast<=0) {
            return;
        }
        statusMessageLabel.setText("Looking For:"+ SearchText + " From:" + VideoIndex + " to:" +VideoLast );

        progressBar.setIndeterminate(true);

        int start=VideoIndex;
        for (int i=start ; i<=VideoLast; i++){
            ScreenContents=ReadScreenContents(i);
            if ( ScreenContents==null) {
                continue;
            }
            if ( ScreenContents.length()==0) {
                continue;
            }

        if ( ScreenContents.contains(SearchText) )  {
                statusMessageLabel.setText("Found:"+ SearchText);
                progressBar.setIndeterminate(false);
                VideoSlider.setValue(i);
                ScreenContentsHighlightStart=ScreenContents.indexOf(SearchText);
                ScreenContentsHighlightEnd=ScreenContentsHighlightStart+SearchText.length();
                ViewCurrentScreenContents();
                ScreenContentsHighlightStart=0;
                ScreenContentsHighlightEnd=0;
                return;
           }


            Pattern mypattern;
            try {
                mypattern=Pattern.compile(SearchText, Pattern.CASE_INSENSITIVE | Pattern.DOTALL | Pattern.MULTILINE) ;
            } catch (PatternSyntaxException ignore) {
                statusMessageLabel.setText("Invalid Search Pattern");
                return;
            }

           Matcher match=mypattern.matcher(ScreenContents);

           /* get only the first match */
           if  (match.find() ){
               VideoSlider.setValue(i);
               statusMessageLabel.setText(match.group() +" " +match.start()+ " " + match.end());
                ScreenContentsHighlightStart=match.start();
                ScreenContentsHighlightEnd=match.end();
                progressBar.setIndeterminate(false);
                ViewCurrentScreenContents();
                ScreenContentsHighlightStart=0;
                ScreenContentsHighlightEnd=0;
                return;
           }

        } /* end for every screen dump */

        progressBar.setIndeterminate(false);
        statusMessageLabel.setText("Could not find:"+SearchText);
    }
    /************************************************************/


    /************************************************************
     *
     *  Asynchronous reader class
     *
     ************************************************************/
    public class Worker implements Runnable {

        File Sessiondir;
        // FileObject FtpSessiondir;

        public Worker() {
            Sessiondir=LastSessiondir;
          //  FtpSessiondir=LastFtpSessiondir;
        }
       
        public void run() {
            while(true) {
                if ( SessionIsRemote){
                    /*
                }
                    if ( (FollowToggled==true) && (LastFtpSessiondir!=null) ){
                        doFtpWork(LastFtpSessiondir);
                        DispImage(VideoIndex); // just in case
                    }

                     */
                }
                else {
                    if ( (FollowToggled==true) && (LastSessiondir!=null) ){
                        doWork(LastSessiondir);
                        DispImage(VideoIndex); // just in case
                    }
                }                         
               Thread.yield();
            }
        }
    }/* end class */
    /************************************************************/


     /************************************************************
     *  Asynchronous Replay class
     ************************************************************/
    public class Player implements Runnable {

        String nonce="";

        public Player() {
            nonce="nonce"; // THis is a nonce
        }

     public void run() {                  
        while (true){
        
        if ( ( Files==null ) || ( Replay==false)){
            Thread.yield();
             continue;
        }
        
        while ( ( VideoIndex<VideoLast) && (Replay==true)  )  {
            int i=VideoIndex;
            String msecs=jSpinner1.getValue().toString();
            i++;
            VideoSlider.setValue(i);
           
            try {
                msecs=jSpinner1.getValue().toString();
                Thread.sleep(Long.parseLong(msecs));
                } catch ( Exception e) {
                   statusMessageLabel.setText(e.getLocalizedMessage());                   
                }
            
        }        
        // Video Play back is done
        if ( ( VideoIndex==VideoLast ) && (Replay==true) ) {
            Replay=false;
            StartReplayButton.setEnabled(true);
            StopReplayButton.setEnabled(false);
            VideoSlider.setEnabled(true);
        }
       }
     }    
  } /* end Asynchronous Replay class */


  /************************************************************/
} /* end of RautorViewerView */
