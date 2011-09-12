/*
 * Viewer.java Author: Angelos Karageorgiou angelos@unix.gr
 * Ah fill in the blanks :-)

 Copyright (c) 2009, Angelos Karageorgiou All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
  *   Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
  *   Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
  *   Neither the name of the Copyright holder nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.
  *   All advertising materials mentioning features or use of this software
      must display the following acknowledgement:
      This product includes software developed by Angelos Karageorgiou

THIS SOFTWARE IS PROVIDED BY Angelos Karageorgiou ''AS IS'' AND ANY
EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Angelos Karageorgiou BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.




 */

package MultiViewer;


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
import javax.swing.JScrollPane;
import java.util.Arrays;
import java.util.regex.*;
import java.nio.charset.Charset;
import java.util.Locale;
import net.sf.vfsjfilechooser.utils.VFSUtils;
import net.sf.vfsjfilechooser.*;
import net.sf.vfsjfilechooser.accessories.*;
import java.awt.*;
import java.awt.image.*;
import java.awt.geom.AffineTransform;
import java.io.*;
import javax.imageio.*;
import java.awt.event.ItemEvent;
import org.apache.commons.vfs.FileContent;
import org.apache.commons.vfs.FileObject;
import java.util.ArrayList;
import java.util.Iterator;


/*
 * The main class or start of the program
 * */

public class Viewer extends FrameView {
    // Global Class variables
    // When I grow up I will turn it into a message passing system :-)
        File LastSessiondir;
        FileObject LastFtpSessiondir;
        static String[] Files;
        static String FullPath,FullFtpPath;
        Boolean FollowToggled=false,Running=false,Replay=false;        
        public static int VideoIndex=0,VideoLast=0;
        boolean scale=false;
        String AppName="MultiViewer";
        Boolean FitImages=true;        
        int ScreenContentsHighlightStart=0,ScreenContentsHighlightEnd=0;
        public String CurrentScreenContents="",ScreenContents="";
        public String SearchText="";
        boolean EscapedSearch=false;
        boolean SessionIsRemote=false;
        String localCharset = Charset.defaultCharset().toString();        
        OtherMonitor[] Monitors =new OtherMonitor[3];
        String NOW="";
        final int DATELENGTH=15;
        boolean HideOtherMonitors=false;        
        
    private void initVars(){
        LastSessiondir=null;
        LastFtpSessiondir=null;
        Files=null;
        FullPath=null;FullFtpPath=null;
        FollowToggled=false;
        Running=false;
        Replay=false;
        VideoIndex=0;VideoLast=0;
        scale=false;
        FitImages=true;               
        ScreenContentsHighlightStart=0;
        ScreenContentsHighlightEnd=0;
        SearchText="";CurrentScreenContents="";ScreenContents="";
        EscapedSearch=false;
        SessionIsRemote=false;
        ScreenLabel.setIcon(getResourceMap().getIcon("ScreenLabel.icon"));
        ScreenLabel.setText(null);
        NowLabel.setText(null);
        statusMessageLabel.setText(null);
        StopReplayButton.setEnabled(false);
        StartReplayButton.setEnabled(false);
        VideoSlider.setEnabled(false);
        FollowButton.setEnabled(false);
        localCharset=LocaleToCharsetMap.getCharset(Locale.getDefault());
        NOW="";        
        HideOtherMonitors=false;
        VideoSlider.setToolTipText("");
        VideoSlider.setValue(0);
        KeyLog.setText("");
        for (int i=0;i<3;i++){
          if (Monitors[i]!=null){
                Monitors[i].dispose();
                Monitors[i]=null;
             }
        }        
    }
       
    public Viewer(SingleFrameApplication app) {
        super(app);

        initComponents();
        initVars();
        
        // status bar initialization - message timeout, idle icon and busy animation, etc
        ResourceMap resourceMap = getResourceMap();
        int messageTimeout = resourceMap.getInteger("StatusBar.messageTimeout");
        messageTimer = new Timer(messageTimeout, new ActionListener() {
            @Override
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
            @Override
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
            @Override
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
    }



/*
 *******************************************
 */
    @Action
    public void showAboutBox() {
        if (aboutBox == null) {
            JFrame mainFrame = MultiViewerApp.getApplication().getMainFrame();
            aboutBox = new AboutBox(mainFrame);
            aboutBox.setLocationRelativeTo(mainFrame);
        }
        MultiViewerApp.getApplication().show(aboutBox);
    }
/*
 *******************************************
 */
    public void showEditorBox(String Title,String MyContents,int Start,int End) {
        JDialog textViewer;

        JFrame mainFrame = MultiViewerApp.getApplication().getMainFrame();
        textViewer = new TextBox(mainFrame,MyContents,Start,End);
        textViewer.setLocationRelativeTo(mainFrame);
        textViewer.setTitle(AppName + "  " + Title);
        MultiViewerApp.getApplication().show(textViewer);
    }

    @Action
    public void Rewind() {
        VideoSlider.setValue(0);
    }

    @Action
    public void ShowOtherMonitors() {
        for ( int i=0;i<3;i++){
            if ( Monitors[i]!=null){
                Monitors[i].setVisible(true);
            }
        }
        HideOtherMonitors=false;
    }

    @Action
    public void HideOtherMonitors() {
        for ( int i=0;i<3;i++){
            if ( Monitors[i]!=null){
                Monitors[i].setVisible(false);
            }
        }
        HideOtherMonitors=true;
    }


    // Create an instance of OtheMonitor and show it
    public OtherMonitor showMonitor(OtherMonitor OMonitor,ImageIcon image) {        
        if ( OMonitor == null ){
            OMonitor = new OtherMonitor();
            OMonitor.setTitle(AppName + " Monitor 2");
        }
        if (! OMonitor.isVisible() ){
            MultiViewerApp.getApplication().show(OMonitor);
        }
        OMonitor.setImage(image);        
        OMonitor.setTitle(AppName + " Monitor 2:"+NOW);
        OMonitor.ShowImage();
        return OMonitor;
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
        ScreenLabel = new javax.swing.JLabel();
        menuBar = new javax.swing.JMenuBar();
        javax.swing.JMenu fileMenu = new javax.swing.JMenu();
        LocalSessionjMenuItem = new javax.swing.JMenuItem();
        RemoteSessionjMenuItem = new javax.swing.JMenuItem();
        ReloadSessionjMenuItem = new javax.swing.JMenuItem();
        javax.swing.JMenuItem exitMenuItem = new javax.swing.JMenuItem();
        jMenu1 = new javax.swing.JMenu();
        jMenuItem4 = new javax.swing.JMenuItem();
        jMenuItem5 = new javax.swing.JMenuItem();
        jMenuItem2 = new javax.swing.JMenuItem();
        jMenu2 = new javax.swing.JMenu();
        FitImagesMenuItem = new javax.swing.JCheckBoxMenuItem();
        jMenu4 = new javax.swing.JMenu();
        SearchMenuItem = new javax.swing.JMenuItem();
        FindNextjMenuItem = new javax.swing.JMenuItem();
        jMenu5 = new javax.swing.JMenu();
        jMenuItemShow = new javax.swing.JMenuItem();
        jMenuItemHide = new javax.swing.JMenuItem();
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
        jButton2 = new javax.swing.JButton();
        NowLabel = new javax.swing.JLabel();
        jSeparator1 = new javax.swing.JSeparator();
        jButton1 = new javax.swing.JButton();
        jPanel1 = new javax.swing.JPanel();
        buttonGroup1 = new javax.swing.ButtonGroup();

        org.jdesktop.application.ResourceMap resourceMap = org.jdesktop.application.Application.getInstance(MultiViewer.MultiViewerApp.class).getContext().getResourceMap(Viewer.class);
        mainPanel.setBackground(resourceMap.getColor("mainPanel.background")); // NOI18N
        mainPanel.setBorder(new javax.swing.border.MatteBorder(null));
        mainPanel.setMinimumSize(new java.awt.Dimension(300, 300));
        mainPanel.setName("mainPanel"); // NOI18N
        mainPanel.setPreferredSize(new java.awt.Dimension(300, 300));

        jScrollPane1.setBackground(new java.awt.Color(153, 153, 153));
        jScrollPane1.setName("jScrollPane1"); // NOI18N
        jScrollPane1.setPreferredSize(new java.awt.Dimension(0, 0));

        ScreenLabel.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
        ScreenLabel.setIcon(resourceMap.getIcon("ScreenLabel.icon")); // NOI18N
        ScreenLabel.setText(resourceMap.getString("ScreenLabel.text")); // NOI18N
        ScreenLabel.setToolTipText(resourceMap.getString("ScreenLabel.toolTipText")); // NOI18N
        ScreenLabel.setDoubleBuffered(true);
        ScreenLabel.setFocusable(false);
        ScreenLabel.setHorizontalTextPosition(javax.swing.SwingConstants.CENTER);
        ScreenLabel.setInheritsPopupMenu(false);
        ScreenLabel.setName("ScreenLabel"); // NOI18N
        ScreenLabel.setOpaque(true);
        ScreenLabel.addComponentListener(new java.awt.event.ComponentAdapter() {
            public void componentResized(java.awt.event.ComponentEvent evt) {
                ScreenLabelComponentResized(evt);
            }
        });
        jScrollPane1.setViewportView(ScreenLabel);

        javax.swing.GroupLayout mainPanelLayout = new javax.swing.GroupLayout(mainPanel);
        mainPanel.setLayout(mainPanelLayout);
        mainPanelLayout.setHorizontalGroup(
            mainPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addComponent(jScrollPane1, javax.swing.GroupLayout.DEFAULT_SIZE, 668, Short.MAX_VALUE)
        );
        mainPanelLayout.setVerticalGroup(
            mainPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addComponent(jScrollPane1, javax.swing.GroupLayout.Alignment.TRAILING, javax.swing.GroupLayout.DEFAULT_SIZE, 376, Short.MAX_VALUE)
        );

        menuBar.setName("menuBar"); // NOI18N

        fileMenu.setForeground(resourceMap.getColor("fileMenu.foreground")); // NOI18N
        fileMenu.setText(resourceMap.getString("fileMenu.text")); // NOI18N
        fileMenu.setName("fileMenu"); // NOI18N

        javax.swing.ActionMap actionMap = org.jdesktop.application.Application.getInstance(MultiViewer.MultiViewerApp.class).getContext().getActionMap(Viewer.class, this);
        LocalSessionjMenuItem.setAction(actionMap.get("PickSession")); // NOI18N
        LocalSessionjMenuItem.setIcon(resourceMap.getIcon("LocalSessionjMenuItem.icon")); // NOI18N
        LocalSessionjMenuItem.setText(resourceMap.getString("LocalSessionjMenuItem.text")); // NOI18N
        LocalSessionjMenuItem.setActionCommand(resourceMap.getString("LocalSessionjMenuItem.actionCommand")); // NOI18N
        LocalSessionjMenuItem.setName("LocalSessionjMenuItem"); // NOI18N
        fileMenu.add(LocalSessionjMenuItem);

        RemoteSessionjMenuItem.setAction(actionMap.get("PickFTPSession")); // NOI18N
        RemoteSessionjMenuItem.setIcon(resourceMap.getIcon("RemoteSessionjMenuItem.icon")); // NOI18N
        RemoteSessionjMenuItem.setText(resourceMap.getString("RemoteSessionjMenuItem.text")); // NOI18N
        RemoteSessionjMenuItem.setActionCommand(resourceMap.getString("RemoteSessionjMenuItem.actionCommand")); // NOI18N
        RemoteSessionjMenuItem.setName("RemoteSessionjMenuItem"); // NOI18N
        fileMenu.add(RemoteSessionjMenuItem);

        ReloadSessionjMenuItem.setAction(actionMap.get("ReloadSession")); // NOI18N
        ReloadSessionjMenuItem.setIcon(resourceMap.getIcon("ReloadSessionjMenuItem.icon")); // NOI18N
        ReloadSessionjMenuItem.setText(resourceMap.getString("ReloadSessionjMenuItem.text")); // NOI18N
        ReloadSessionjMenuItem.setName("ReloadSessionjMenuItem"); // NOI18N
        fileMenu.add(ReloadSessionjMenuItem);

        exitMenuItem.setAction(actionMap.get("quit")); // NOI18N
        exitMenuItem.setIcon(resourceMap.getIcon("exitMenuItem.icon")); // NOI18N
        exitMenuItem.setName("exitMenuItem"); // NOI18N
        fileMenu.add(exitMenuItem);

        menuBar.add(fileMenu);

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

        jMenuItem2.setAction(actionMap.get("ViewCurrentScreenContents")); // NOI18N
        jMenuItem2.setIcon(resourceMap.getIcon("jMenuItem2.icon")); // NOI18N
        jMenuItem2.setText(resourceMap.getString("jMenuItem2.text")); // NOI18N
        jMenuItem2.setName("jMenuItem2"); // NOI18N
        jMenu1.add(jMenuItem2);

        menuBar.add(jMenu1);

        jMenu2.setForeground(resourceMap.getColor("jMenu2.foreground")); // NOI18N
        jMenu2.setText(resourceMap.getString("jMenu2.text")); // NOI18N
        jMenu2.setName("jMenu2"); // NOI18N

        FitImagesMenuItem.setAccelerator(javax.swing.KeyStroke.getKeyStroke(java.awt.event.KeyEvent.VK_Z, java.awt.event.InputEvent.CTRL_MASK));
        FitImagesMenuItem.setSelected(true);
        FitImagesMenuItem.setText(resourceMap.getString("FitImagesMenuItem.text")); // NOI18N
        FitImagesMenuItem.setToolTipText(resourceMap.getString("FitImagesMenuItem.toolTipText")); // NOI18N
        FitImagesMenuItem.setName("FitImagesMenuItem"); // NOI18N
        FitImagesMenuItem.addItemListener(new java.awt.event.ItemListener() {
            public void itemStateChanged(java.awt.event.ItemEvent evt) {
                FitImagesMenuItemItemStateChanged(evt);
            }
        });
        jMenu2.add(FitImagesMenuItem);

        menuBar.add(jMenu2);

        jMenu4.setForeground(resourceMap.getColor("jMenu4.foreground")); // NOI18N
        jMenu4.setText(resourceMap.getString("jMenu4.text")); // NOI18N
        jMenu4.setName("jMenu4"); // NOI18N

        SearchMenuItem.setAction(actionMap.get("OpenSearchTextBox")); // NOI18N
        SearchMenuItem.setText(resourceMap.getString("SearchMenuItem.text")); // NOI18N
        SearchMenuItem.setName("SearchMenuItem"); // NOI18N
        jMenu4.add(SearchMenuItem);

        FindNextjMenuItem.setAction(actionMap.get("FindNext")); // NOI18N
        FindNextjMenuItem.setText(resourceMap.getString("FindNextjMenuItem.text")); // NOI18N
        FindNextjMenuItem.setName("FindNextjMenuItem"); // NOI18N
        FindNextjMenuItem.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                FindNextjMenuItemActionPerformed(evt);
            }
        });
        jMenu4.add(FindNextjMenuItem);

        menuBar.add(jMenu4);

        jMenu5.setText(resourceMap.getString("jMenu5.text")); // NOI18N
        jMenu5.setName("jMenu5"); // NOI18N

        jMenuItemShow.setAction(actionMap.get("ShowOtherMonitors")); // NOI18N
        jMenuItemShow.setText(resourceMap.getString("jMenuItemShow.text")); // NOI18N
        jMenuItemShow.setName("jMenuItemShow"); // NOI18N
        jMenu5.add(jMenuItemShow);

        jMenuItemHide.setAction(actionMap.get("HideOtherMonitors")); // NOI18N
        jMenuItemHide.setText(resourceMap.getString("jMenuItemHide.text")); // NOI18N
        jMenuItemHide.setName("jMenuItemHide"); // NOI18N
        jMenu5.add(jMenuItemHide);

        menuBar.add(jMenu5);

        helpMenu.setText(resourceMap.getString("helpMenu.text")); // NOI18N
        helpMenu.setName("helpMenu"); // NOI18N

        aboutMenuItem.setAction(actionMap.get("showAboutBox")); // NOI18N
        aboutMenuItem.setText(resourceMap.getString("aboutMenuItem.text")); // NOI18N
        aboutMenuItem.setName("aboutMenuItem"); // NOI18N
        helpMenu.add(aboutMenuItem);

        menuBar.add(helpMenu);

        statusPanel.setName("statusPanel"); // NOI18N

        statusMessageLabel.setBackground(resourceMap.getColor("statusMessageLabel.background")); // NOI18N
        statusMessageLabel.setHorizontalAlignment(javax.swing.SwingConstants.LEFT);
        statusMessageLabel.setHorizontalTextPosition(javax.swing.SwingConstants.LEFT);
        statusMessageLabel.setMaximumSize(new java.awt.Dimension(496, 0));
        statusMessageLabel.setName("statusMessageLabel"); // NOI18N
        statusMessageLabel.setRequestFocusEnabled(false);

        statusAnimationLabel.setHorizontalAlignment(javax.swing.SwingConstants.LEFT);
        statusAnimationLabel.setName("statusAnimationLabel"); // NOI18N

        progressBar.setToolTipText(resourceMap.getString("progressBar.toolTipText")); // NOI18N
        progressBar.setName("progressBar"); // NOI18N

        VideoSlider.setMaximum(0);
        VideoSlider.setToolTipText(resourceMap.getString("VideoSlider.toolTipText")); // NOI18N
        VideoSlider.setAutoscrolls(true);
        VideoSlider.setMinimumSize(new java.awt.Dimension(16, 25));
        VideoSlider.setName("VideoSlider"); // NOI18N
        VideoSlider.setPreferredSize(new java.awt.Dimension(20, 25));
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
        StopReplayButton.setToolTipText(resourceMap.getString("StopReplayButton.toolTipText")); // NOI18N
        StopReplayButton.setName("StopReplayButton"); // NOI18N

        jSpinner1.setModel(new javax.swing.SpinnerNumberModel(250, 0, 2000, 10));
        jSpinner1.setToolTipText(resourceMap.getString("jSpinner1.toolTipText")); // NOI18N
        jSpinner1.setName("jSpinner1"); // NOI18N
        jSpinner1.setRequestFocusEnabled(false);

        StartReplayButton.setAction(actionMap.get("Replay")); // NOI18N
        StartReplayButton.setIcon(resourceMap.getIcon("StartReplayButton.icon")); // NOI18N
        StartReplayButton.setToolTipText(resourceMap.getString("StartReplayButton.toolTipText")); // NOI18N
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

        jButton2.setAction(actionMap.get("Rewind")); // NOI18N
        jButton2.setIcon(resourceMap.getIcon("jButton2.icon")); // NOI18N
        jButton2.setToolTipText(resourceMap.getString("jButton2.toolTipText")); // NOI18N
        jButton2.setName("jButton2"); // NOI18N

        NowLabel.setHorizontalAlignment(javax.swing.SwingConstants.RIGHT);
        NowLabel.setText(resourceMap.getString("NowLabel.text")); // NOI18N
        NowLabel.setToolTipText(resourceMap.getString("NowLabel.toolTipText")); // NOI18N
        NowLabel.setHorizontalTextPosition(javax.swing.SwingConstants.RIGHT);
        NowLabel.setName("NowLabel"); // NOI18N

        jSeparator1.setName("jSeparator1"); // NOI18N

        javax.swing.GroupLayout statusPanelLayout = new javax.swing.GroupLayout(statusPanel);
        statusPanel.setLayout(statusPanelLayout);
        statusPanelLayout.setHorizontalGroup(
            statusPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(statusPanelLayout.createSequentialGroup()
                .addContainerGap()
                .addGroup(statusPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addGroup(statusPanelLayout.createSequentialGroup()
                        .addComponent(StartReplayButton, javax.swing.GroupLayout.PREFERRED_SIZE, 33, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addComponent(StopReplayButton, javax.swing.GroupLayout.PREFERRED_SIZE, 33, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addComponent(jSpinner1, javax.swing.GroupLayout.PREFERRED_SIZE, 59, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addComponent(jButton2, javax.swing.GroupLayout.PREFERRED_SIZE, 27, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addComponent(VideoSlider, javax.swing.GroupLayout.DEFAULT_SIZE, 431, Short.MAX_VALUE)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addComponent(FollowButton, javax.swing.GroupLayout.PREFERRED_SIZE, 33, javax.swing.GroupLayout.PREFERRED_SIZE))
                    .addGroup(statusPanelLayout.createSequentialGroup()
                        .addComponent(NowLabel, javax.swing.GroupLayout.PREFERRED_SIZE, 115, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addComponent(KeyLog, javax.swing.GroupLayout.DEFAULT_SIZE, 531, Short.MAX_VALUE))
                    .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, statusPanelLayout.createSequentialGroup()
                        .addComponent(statusMessageLabel, javax.swing.GroupLayout.DEFAULT_SIZE, 496, Short.MAX_VALUE)
                        .addGap(18, 18, 18)
                        .addComponent(progressBar, javax.swing.GroupLayout.PREFERRED_SIZE, 89, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addGap(18, 18, 18)
                        .addComponent(statusAnimationLabel, javax.swing.GroupLayout.PREFERRED_SIZE, 29, javax.swing.GroupLayout.PREFERRED_SIZE)))
                .addContainerGap())
            .addGroup(statusPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                .addComponent(jSeparator1, javax.swing.GroupLayout.DEFAULT_SIZE, 670, Short.MAX_VALUE))
        );
        statusPanelLayout.setVerticalGroup(
            statusPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(statusPanelLayout.createSequentialGroup()
                .addGroup(statusPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(KeyLog, javax.swing.GroupLayout.PREFERRED_SIZE, 19, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addComponent(NowLabel, javax.swing.GroupLayout.PREFERRED_SIZE, 19, javax.swing.GroupLayout.PREFERRED_SIZE))
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addGroup(statusPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addGroup(statusPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.TRAILING)
                        .addComponent(VideoSlider, javax.swing.GroupLayout.PREFERRED_SIZE, 35, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addGroup(javax.swing.GroupLayout.Alignment.LEADING, statusPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.TRAILING, false)
                            .addComponent(jButton2, javax.swing.GroupLayout.Alignment.LEADING, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                            .addComponent(jSpinner1, javax.swing.GroupLayout.Alignment.LEADING)
                            .addComponent(StartReplayButton, javax.swing.GroupLayout.Alignment.LEADING, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                            .addComponent(StopReplayButton, javax.swing.GroupLayout.Alignment.LEADING, javax.swing.GroupLayout.DEFAULT_SIZE, 35, Short.MAX_VALUE)))
                    .addComponent(FollowButton, javax.swing.GroupLayout.PREFERRED_SIZE, 34, javax.swing.GroupLayout.PREFERRED_SIZE))
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addGroup(statusPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addComponent(statusMessageLabel, javax.swing.GroupLayout.DEFAULT_SIZE, 27, Short.MAX_VALUE)
                    .addComponent(statusAnimationLabel, javax.swing.GroupLayout.Alignment.TRAILING, javax.swing.GroupLayout.DEFAULT_SIZE, 27, Short.MAX_VALUE)
                    .addComponent(progressBar, javax.swing.GroupLayout.Alignment.TRAILING, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)))
            .addGroup(statusPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                .addGroup(statusPanelLayout.createSequentialGroup()
                    .addGap(60, 60, 60)
                    .addComponent(jSeparator1, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addContainerGap(31, Short.MAX_VALUE)))
        );

        jSpinner1.getAccessibleContext().setAccessibleDescription(resourceMap.getString("jSpinner1.AccessibleContext.accessibleDescription")); // NOI18N
        NowLabel.getAccessibleContext().setAccessibleDescription(resourceMap.getString("NowLabel.AccessibleContext.accessibleDescription")); // NOI18N

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

    private void ScreenLabelComponentResized(java.awt.event.ComponentEvent evt) {//GEN-FIRST:event_ScreenLabelComponentResized
        DispImage(VideoIndex);
    }//GEN-LAST:event_ScreenLabelComponentResized

    private void FindNextjMenuItemActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_FindNextjMenuItemActionPerformed
        // TODO add your handling code here:
    }//GEN-LAST:event_FindNextjMenuItemActionPerformed

    private void FitImagesMenuItemItemStateChanged(java.awt.event.ItemEvent evt) {//GEN-FIRST:event_FitImagesMenuItemItemStateChanged
        if (evt.getStateChange() == ItemEvent.SELECTED ){
            FitImages=true;
        } else {
            FitImages=false;
        }
        DispImage(VideoIndex);
    }//GEN-LAST:event_FitImagesMenuItemItemStateChanged


    /*
     *
     * Most of the display work takes place here
     *
     *
     */
    public  void DispImage(final int Index){
        if ( Files == null ){
//      No session is active yet!
            statusMessageLabel.setText("No PNG Images found yet");
            return;
        }
        if ( Index > VideoLast) {
            statusMessageLabel.setText("Image Not created yet...");
            return;
        }

        Thread shower = new Thread() { // asynchronously show images
            public void run(){
                busyIconTimer.start();
                if ( FitImages==false) {
                        ShowUnscaledImage(Index);
                }else { // Scaled Image
                        ShowScaledImage(Index);
                }
                busyIconTimer.stop();
                statusAnimationLabel.setIcon(idleIcon);
            }
        };
        shower.run();

        int len=Files[Index].length();
//        NOW=Files[Index].substring(len-(DATELENGTH+4),len-4);
        int o=len-(DATELENGTH+4);
        String Year=Files[Index].substring(o,o+4);
        String Mon=Files[Index].substring(o+4,o+6);
        String Day=Files[Index].substring(o+6,o+8);
        String Hour=Files[Index].substring(o+9,o+11);
        String Min=Files[Index].substring(o+11,o+13);
        String Sec=Files[Index].substring(o+13,o+15);
        NOW=Year+"/"+Mon+"/"+Day+" "+Hour+":"+Min+":"+Sec;
        VideoSlider.setToolTipText(NOW);
        ViewCurrentKeyboardLog();
    }

    // *************************************

void ShowUnscaledImage(int val){
    ImageIcon myimage=null;
    ImageIcon[] MyImages=new ImageIcon[3];
    Image scaled,unscaled;


     String FriendlyName="";
     if (SessionIsRemote){
            if ( FullFtpPath==null) {
                statusMessageLabel.setText("Application is initialing");
                return;
            }          
            FriendlyName=VFSUtils.getFriendlyName(Files[val]);
            try {
                FileObject RemoteFile=VFSUtils.createFileObject(Files[val]);
                InputStream is=VFSUtils.getInputStream(RemoteFile);
                Image tmpimage = ImageIO.read(is);                
                myimage=new ImageIcon(tmpimage);                
            } catch ( Exception e){
                myimage=null;
                statusMessageLabel.setText("Could not read:"+FriendlyName  );
            }
        }  else { // Session is local         
            FriendlyName=Files[val];
            try {
                    myimage=new ImageIcon(FullPath+"\\"+Files[val]);
        
                } catch ( Exception e) {
                    statusMessageLabel.setText(e.getLocalizedMessage() + " " +  Files[val]);
                }
       }
     ScreenLabel.setIcon(myimage);
     if ( HideOtherMonitors==true){
         return;
     }

     // Other monitors should display here !



    String[] LocalPaths=new String[3];
    for ( int i=0;i<3;i++){
        LocalPaths[i]=FullPath+" Monitor" +(i+2); // monitor2 monitor3
    }

    String[] FtpPaths=new String[3];
    for ( int i=0;i<3;i++){
        FtpPaths[i]=FullFtpPath+" Monitor" +(i+2); // monitor2 monitor3
    }

     if ( SessionIsRemote == true ) {
        for ( int i=0;i<3;i++){
            try {
                int pl=FullFtpPath.length();
                String ProperFileName=Files[val].substring(pl);
                FileObject RemoteFile=VFSUtils.createFileObject(FtpPaths[i]+ProperFileName);
                InputStream is=VFSUtils.getInputStream(RemoteFile);
                Image tmpimage = ImageIO.read(is);
                MyImages[i]=new ImageIcon(tmpimage);
            } catch ( Exception e){
                MyImages[i]=null;
            }
        }
     }else {
        for (int i=0;i<3;i++){
            try {
               MyImages[i]=new ImageIcon(LocalPaths[i]+"\\"+Files[val]);
            } catch ( Exception e) {
                    MyImages[i]=null;
            }
       }
     }


     // do not hide the other monitors
      for (int i=0;i<3;i++){
          if ( MyImages[i]==null) {
              continue;
          }
         if ( MyImages[i].getImageLoadStatus() !=MediaTracker.COMPLETE ) {
             continue;
         }
         if ( Monitors[i] == null) {
                Monitors[i]=showMonitor(Monitors[i],MyImages[i]);
         }else {
             showMonitor(Monitors[i],MyImages[i]);
         }
        }
}



void ShowScaledImage(int val){
    ImageIcon myimage=null;
    ImageIcon[] myImages=new ImageIcon[3];
    Image scaled,unscaled;
    Image[] RawImages=new Image[3];


    
    String FriendlyName="";
    VFSUtils.getFriendlyName(Files[val]);
    if ( SessionIsRemote){
        FriendlyName=VFSUtils.getFriendlyName(Files[val]);        
        try {
            FileObject RemoteFile=VFSUtils.createFileObject(Files[val]);
            InputStream is=VFSUtils.getInputStream(RemoteFile);
            unscaled = ImageIO.read(is);
        } catch ( Exception e){
            statusMessageLabel.setText("Could not Read:"+FriendlyName  );
            return;
        }
    } else { // read local files
        FriendlyName=Files[val];
        try {
            unscaled=ImageIO.read(new File(FullPath+"\\"+Files[val]));
        } catch (Exception e) {
            statusMessageLabel.setText(e.getLocalizedMessage() + " " +  Files[val] );
           return;
        }
    }
    scaled=doScale(unscaled,jScrollPane1);

    if (scaled ==null) {
       statusMessageLabel.setText("Could not scale image:"+FriendlyName);
    } else {
        ScreenLabel.setIcon(new ImageIcon(scaled));
    }

   if ( HideOtherMonitors==true){
        return;
    }
    
    
    // Get here only if we are displaying the other monitors
    String[] FtpPaths=new String[3];
    for ( int i=0;i<3;i++){
        FtpPaths[i]=FullFtpPath+" Monitor" +(i+2); // monitor2 monitor3
    }
    String[] LocalPaths=new String[3];
    for ( int i=0;i<3;i++){
        LocalPaths[i]=FullPath+" Monitor" +(i+2); // monitor2 monitor3
    }



        // try other monitors
    if ( SessionIsRemote==true) {
        for ( int i=0;i<3;i++){
            try {
                int pl=FullFtpPath.length();
                String ProperFileName=Files[val].substring(pl);
                FileObject RemoteFile=VFSUtils.createFileObject(FtpPaths[i]+ProperFileName);
                InputStream is=VFSUtils.getInputStream(RemoteFile);
                RawImages[i]= ImageIO.read(is);
            } catch ( Exception e){
                RawImages[i]=null;
            }
        }
    } else {
        // Try OtherMonitors
        for ( int i=0;i<3;i++){
            try {
                RawImages[i]=ImageIO.read(new File(LocalPaths[i]+"/"+Files[val]));
            } catch (Exception e){
                RawImages[i]=null;
            }
        }
    }

    
    // Do not hide other monitors
    for ( int i=0;i<3; i++){
        if (RawImages[i] == null){
            continue;
        }
        if ( Monitors[i] == null) {
            Monitors[i]=showMonitor(Monitors[i],new ImageIcon(RawImages[i]));
        } else {
            showMonitor(Monitors[i],new ImageIcon(RawImages[i]));
        }
    }
 }

    
// ************************************

public static Image doScale(Image unscaled, JScrollPane Pane ){
    if ( unscaled == null){
        return(null);
    }
    int Iwidth=unscaled.getWidth(null);
    int Iheight= unscaled.getHeight(null);
    int Pwidth=Pane.getWidth()-10;
    int Pheight=Pane.getHeight()-10;
    BufferedImage raw=toBufferedImage(unscaled);
    
    // raw = new BufferedImage(width, height, BufferedImage.TYPE_INT_RGB);

        
        float wscale=(float)Pwidth/(float)Iwidth;
        float hscale=(float)Pheight/(float)Iheight;

        // scaled=unscaled.getScaledInstance(width, height, ScaleAlgorithm);
        BufferedImageOp op = new AffineTransformOp(
              AffineTransform.getScaleInstance(wscale, hscale),
              new RenderingHints(RenderingHints.KEY_INTERPOLATION,
                                 RenderingHints.VALUE_INTERPOLATION_BICUBIC));

        BufferedImage rawscaled = op.filter(raw, null);
        return(Toolkit.getDefaultToolkit().createImage(rawscaled.getSource()));
}




// **************************************

    @Action
    public void PickSession() {
        File Sessiondir;        
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
        int returnVal = fc.showOpenDialog(mainPanel);
        System.setSecurityManager(backup);
        if (returnVal == JFileChooser.APPROVE_OPTION) {
            initVars();
            statusMessageLabel.setText("Reading Directory Listing");
             Sessiondir = fc.getSelectedFile();            
             LastSessiondir= new File (Sessiondir.getPath());
        } else {
            Sessiondir = fc.getCurrentDirectory();
            LastSessiondir= new File (Sessiondir.getPath());
            statusMessageLabel.setText("Open command cancelled by user.");
            busyIconTimer.stop();
            statusAnimationLabel.setIcon(idleIcon);
            return;
        }
        VideoSlider.setEnabled(false);
        StartReplayButton.setEnabled(false);

        if ( FollowToggled==true){
            FollowButton.doClick();
        }
        Thread doer=new Thread(){
            @Override
            public void run () {
                busyIconTimer.start();
                
                doLocalWork(LastSessiondir,true);
                busyIconTimer.stop();
                statusAnimationLabel.setIcon(idleIcon);
                VideoSlider.setValue(0);
            }
        };
        doer.start();
    }

@Action
public void PickFTPSession() {
        final FileObject Sessiondir ;
        String FName;        
        SecurityManager backup = System.getSecurityManager();
 
        System.setSecurityManager(null);        
        messageTimer.setRepeats(true);

       /* VFS FTP */
        // create a file chooser that will be something to look into
        VFSJFileChooser fileChooser = new VFSJFileChooser();
        
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
    if (answer == VFSJFileChooser.RETURN_TYPE.APPROVE){
               initVars();
             FName =   fileChooser.getSelectedFile().toString();
             statusMessageLabel.setText("Reading Directory Listing");
             Sessiondir =   fileChooser.getSelectedFile();
             LastFtpSessiondir = Sessiondir;             
        } else {
            Sessiondir =   fileChooser.getCurrentDirectory();
             LastFtpSessiondir = Sessiondir;
            statusMessageLabel.setText("Open command cancelled by user.");
            busyIconTimer.stop(); 
            statusAnimationLabel.setIcon(idleIcon);            
            return;
        }
        VideoSlider.setEnabled(false);
        StartReplayButton.setEnabled(false);

        if ( FollowToggled==true){
            FollowButton.doClick();
        }

        // now spawn thyself
        Thread doer = new Thread() {
            @Override
            public void run(){                
                busyIconTimer.start();
                if (  ! Sessiondir.toString().contains("file://") ){
                    SessionIsRemote=true;
                    try  {
                            doFtpWork(LastFtpSessiondir,true);
                        } catch ( Exception e){
                            statusMessageLabel.setText(e.getLocalizedMessage());
                        }
                } else {
                    SessionIsRemote=false;
                    File LocalSessionDir = new File(Sessiondir.toString().substring(8));
                    doLocalWork(LocalSessionDir,true);
                }
                busyIconTimer.stop();
                statusAnimationLabel.setIcon(idleIcon);
                VideoSlider.setValue(0);
            }
        };
        doer.start();
}

    @Action
    public void ReloadSession() {
        if ( SessionIsRemote) {
            if ( LastFtpSessiondir == null) {
                statusMessageLabel.setText("No session loaded");
                return;
            }
            busyIconTimer.start();
            try {
                doFtpWork(LastFtpSessiondir,false);
            } catch ( Exception e) {
                statusMessageLabel.setText(e.getLocalizedMessage());
            }
            busyIconTimer.stop();
            statusAnimationLabel.setIcon(idleIcon);
        } else {
            if ( LastSessiondir == null) {
                statusMessageLabel.setText("No session loaded");
                return;
            }
            busyIconTimer.start();
            doLocalWork(LastSessiondir,false);
            busyIconTimer.stop();
            statusAnimationLabel.setIcon(idleIcon);
        }
    }


    public void doFtpWork(FileObject Sessiondir,boolean rewind) throws Exception{
        int i=0;
        ArrayList<String> AllFiles = new ArrayList<String>();

        FullFtpPath=Sessiondir.toString();
        FullPath=VFSUtils.getFriendlyName(FullFtpPath);

        for ( FileObject filename : Sessiondir.getChildren()){
            String Fname=filename.toString();
            AllFiles.add(Fname);            
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
        if ( Files != null ) {
            Files=null;
        }
        Files=new String[i];

       
        i=0;
        Iterator IterAll = AllFiles.iterator();
        while (IterAll.hasNext()) {
            String Fname = (String) IterAll.next();
            if (Fname.contains(".png") ||Fname.contains(".PNG")   ){                
                Files[i]=Fname;
                i++;                
            }
        }
        i--;
        SetupGui(i,rewind);
      }


    /*
     * Read all the files from a local/LAN disk
     *
     */

    public void doLocalWork(File Sessiondir,boolean rewind){
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
            }
            
        }
        i--;       
        SetupGui(i,rewind);

    }


    void SetupGui(int imagecount,boolean rewind){
        VideoLast=imagecount;
        VideoSlider.setMaximum(VideoLast);
        VideoSlider.setEnabled(true);
        StartReplayButton.setEnabled(true);
        FollowButton.setEnabled(true);

        // Display the first or the last image ?
        
        JFrame mainFrame = MultiViewerApp.getApplication().getMainFrame();
        mainFrame.setTitle(AppName+" "+FullPath);
        
        progressBar.setMaximum(VideoLast);
        if ( rewind == true ) {
            VideoSlider.setValue(0);
        } // just in case;
    }

    @Action
    public void FollowUser()  {
        if ( SessionIsRemote) {
            if ( LastFtpSessiondir == null) {
                statusMessageLabel.setText("No session loaded");
                return;
            }
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
            progressBar.setVisible(true);
            progressBar.setIndeterminate(true);
            doTheFollowing();
        } else {
            progressBar.setVisible(false);
            progressBar.setValue(0);
            FollowToggled=false;
        }        
    }


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
         Thread LocalPlayer =new Thread() {
            @Override
                public void run() {
                if ( ( Files==null ) || ( Replay==false)){
                     return;
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
         };
         LocalPlayer.start();
}

    // Variables declaration - do not modify//GEN-BEGIN:variables
    private javax.swing.JMenuItem FindNextjMenuItem;
    private javax.swing.JCheckBoxMenuItem FitImagesMenuItem;
    private javax.swing.JToggleButton FollowButton;
    private javax.swing.JTextField KeyLog;
    private javax.swing.JMenuItem LocalSessionjMenuItem;
    private javax.swing.JLabel NowLabel;
    private javax.swing.JMenuItem ReloadSessionjMenuItem;
    private javax.swing.JMenuItem RemoteSessionjMenuItem;
    private javax.swing.JLabel ScreenLabel;
    private javax.swing.JMenuItem SearchMenuItem;
    private javax.swing.JButton StartReplayButton;
    private javax.swing.JButton StopReplayButton;
    private javax.swing.JSlider VideoSlider;
    private javax.swing.ButtonGroup buttonGroup1;
    private javax.swing.JButton jButton1;
    private javax.swing.JButton jButton2;
    private javax.swing.JMenu jMenu1;
    private javax.swing.JMenu jMenu2;
    private javax.swing.JMenu jMenu4;
    private javax.swing.JMenu jMenu5;
    private javax.swing.JMenuItem jMenuItem2;
    private javax.swing.JMenuItem jMenuItem4;
    private javax.swing.JMenuItem jMenuItem5;
    private javax.swing.JMenuItem jMenuItemHide;
    private javax.swing.JMenuItem jMenuItemShow;
    private javax.swing.JPanel jPanel1;
    private javax.swing.JScrollPane jScrollPane1;
    private javax.swing.JSeparator jSeparator1;
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
    
    @Action
    public void ViewFullKeyboardLog() {
        BufferedReader FKL;
        String FullKeyboardLog="";

        if ( Files == null ) {
            statusMessageLabel.setText("No session loaded");
            return;
        }

        if ( SessionIsRemote){
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
//                String FriendlyName=VFSUtils.getFriendlyName(FullFtpPath+"/KeyBoard_Log.txt");
//                statusMessageLabel.setText("Could not Find:"+FriendlyName);
                statusMessageLabel.setText("Cannot read the full keyboard log");
                return;
            }
        } else {
            try {
                FKL=new BufferedReader(new FileReader(FullPath+"\\KeyBoard_Log.txt"));
                while (FKL.ready()){
                   String line=FKL.readLine();
                    FullKeyboardLog=FullKeyboardLog + line +"\n";
                }
           }catch (IOException e) {
//                statusMessageLabel.setText(e.getLocalizedMessage());
                statusMessageLabel.setText("Cannot read the full keyboard log");
                return;
                }
        }
        showEditorBox("Full Keyboard Log ",FullKeyboardLog,0,0);
    }

    @Action
    public void ViewSessionLog() {
        BufferedReader FKL;
        String SessionLog="";

        if ( Files==null){
            statusMessageLabel.setText("No session loaded");
            return;
        }
        if ( SessionIsRemote){
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
//                String FriendlyName=VFSUtils.getFriendlyName(FullFtpPath+"/Session_Log.txt");
//                statusMessageLabel.setText("Could not Find:"+FriendlyName);
                statusMessageLabel.setText("Cannot read the Session Log File");
                return;
            }
        } else {
            try {
                FKL=new BufferedReader(new FileReader(FullPath+"\\Session_Log.txt"));
                while (FKL.ready()){
                    String line=FKL.readLine();
                    SessionLog=SessionLog + line +"\n";
                }
            }catch (IOException e) {
                // statusMessageLabel.setText(e.getLocalizedMessage());
                statusMessageLabel.setText("Cannot read the Session Log File");
                return;
            }
        }
        showEditorBox("Full Session Log",SessionLog,0,0);
    }

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
//                String FriendlyName=VFSUtils.getFriendlyName(Kfname);
//                statusMessageLabel.setText("Could not Find:"+FriendlyName);
                KeyboardLog="";
//angelos                statusMessageLabel.setText("Cannot read current timeslice's KeyLog");
            }

        } else {
            try {
                FKL=new BufferedReader(new FileReader(FullPath+"\\"+ Kfname));
                while (FKL.ready()){
                    String line=FKL.readLine();
                    if ( line != null ) {
                        if ( line.length()>16)
                            KeyboardLog=KeyboardLog + line.substring(16);
                    }
                }
            }catch (IOException e) {
//                statusMessageLabel.setText(e.getLocalizedMessage());
//angelos                statusMessageLabel.setText("Cannot read current timeslice's KeyLog");
                KeyboardLog="";
                }
        }       
        
        KeyLog.setText(KeyboardLog);
        NowLabel.setText(NOW);
    }


@Action
public void ViewCurrentScreenContents() {
        CurrentScreenContents=ReadScreenContents(VideoIndex);
        if (CurrentScreenContents==null){
            statusMessageLabel.setText("Cannot read current Timeslice's Screen contents");
            return;
        }
       if ( CurrentScreenContents.length()!=0) {
            showEditorBox("Current Screen Contents "+NOW,CurrentScreenContents,ScreenContentsHighlightStart,ScreenContentsHighlightEnd);
       } else {
            statusMessageLabel.setText("Cannot read current Timeslice's Screen contents");
       }
}

public String ReadScreenContents(int i) {
        BufferedReader FKL;
        StringBuilder Contents = new StringBuilder();
        if  (Files==null)  {
//            statusMessageLabel.setText("No session loaded"); errors in calling function
            return null;
        }        
        
        int Fl=Files[i].length();
        String Pfname=Files[i].substring(0,Fl-4); // remove .png
        String fname=Pfname+"-ScreenContents.txt";
         
      if ( SessionIsRemote){
          try {
              FileObject RemoteFile=VFSUtils.createFileObject(fname);
              InputStream is=VFSUtils.getInputStream(RemoteFile);
              String friendlyname=VFSUtils.getFriendlyName(fname);              

              FKL=new BufferedReader(new InputStreamReader(is,localCharset));                 
                String line;
                do {
                    line=FKL.readLine();
                    if ( line !=null ){
                        Contents.append(line);
                        Contents.append("\n");
                    }
                } while (line !=null);         
        }catch (IOException e) {
//                String FriendlyName=VFSUtils.getFriendlyName(fname);
//                statusMessageLabel.setText("Could not Find:"+FriendlyName);
                return null;
        }
      }else { // session is local
        try {         
            FKL=new BufferedReader(new InputStreamReader(new FileInputStream(FullPath+"\\"+fname),localCharset));
            String friendlyname=FullPath+"\\"+fname;            
            while (FKL.ready()){
                String line=FKL.readLine();
                    if ( line !=null ){
                        Contents.append(line);
                        Contents.append("\n");
                    }
            }
        }catch (IOException e) {
//                String friendlyname=FullPath+"\\"+fname;
//                statusMessageLabel.setText("Could not read:"+friendlyname);
                return null;
        }
      }
      return Contents.toString();
}


    @Action
    public void OpenSearchTextBox() {
    JDialog SearchtextBoxDialog;

        StopReplayButton.doClick();
        progressBar.setValue(0);
        JFrame mainFrame = MultiViewerApp.getApplication().getMainFrame();
        SearchtextBoxDialog =new SearchTextBox(mainFrame,true);
        SearchtextBoxDialog.setLocationRelativeTo(mainFrame);
        SearchtextBoxDialog.setTitle(AppName + "  Look for Text");
        MultiViewerApp.getApplication().show(SearchtextBoxDialog);

        SearchText=SearchTextBox.getTextField();
        if ( SearchText != null) {
            progressBar.setValue(VideoIndex);
            lookfor(SearchText);            
            progressBar.setValue(0);            
        }
        progressBar.setValue(0);
    }

@Action
public void FindNext(){
    progressBar.setValue(0);
    if ( SearchText != null) { 
        VideoIndex++;
        VideoSlider.setValue(VideoIndex);
        progressBar.setValue(VideoIndex);       
        lookfor(SearchText);
        progressBar.setValue(0);        
     }
}



    public void lookfor(final String SearchText){
        Thread Looker = new Thread() {
          @Override
          public void run() {            
                if (VideoLast<=0) {
                    return;
                }
                int start=VideoIndex;

                for (int i=start ; i<=VideoLast; i++){
                    progressBar.setValue(i);
                    ScreenContents=ReadScreenContents(i);
                    if ( ScreenContents==null) {
                        continue;
                    }
                    if ( ScreenContents.length()==0) {
                        continue;
                    }

                if ( ScreenContents.contains(SearchText) )  {
                        progressBar.setValue(0);
        //                statusMessageLabel.setText("Found:"+ SearchText);
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
                       progressBar.setValue(0);
                       statusMessageLabel.setText(match.group() +" " +match.start()+ " " + match.end());
                       ScreenContentsHighlightStart=match.start();
                       ScreenContentsHighlightEnd=match.end();
                       ViewCurrentScreenContents();
                       ScreenContentsHighlightStart=0;
                       ScreenContentsHighlightEnd=0;
                       return;
                   }

                } /* end for every screen dump */
                statusMessageLabel.setText("Could not find:"+SearchText);
                progressBar.setValue(0);
            }
        };
        Looker.start();
    }


    public void doTheFollowing(){       
        Thread Follower = new Thread(){
            @Override
        public void run() {
            while (FollowToggled==true) {                
                try {  
                    Thread.sleep(1333);
                } catch ( Exception e) {
                       statusMessageLabel.setText(e.getLocalizedMessage());
                }                
                if ( SessionIsRemote){
                    if (LastFtpSessiondir!=null) {
                        try  {
                            doFtpWork(LastFtpSessiondir,false);
                        } catch ( Exception e){
                            statusMessageLabel.setText(e.getLocalizedMessage());
                        }                        
                    }
                }
                else {
                    if ( LastSessiondir!=null) {
                        doLocalWork(LastSessiondir,false);
                    }
                }
                // session has now been reloaded
                VideoSlider.setValue(VideoLast); 
              }
        }
    };
    Follower.start();    
  }

    // This method returns a buffered image with the contents of an image
    public static BufferedImage toBufferedImage(Image image) {
        if (image instanceof BufferedImage) {
            return (BufferedImage)image;
        }

        // This code ensures that all the pixels in the image are loaded
        image = new ImageIcon(image).getImage();

        // Create a buffered image with a format that's compatible with the screen
        BufferedImage bimage = null;
        GraphicsEnvironment ge = GraphicsEnvironment.getLocalGraphicsEnvironment();
        try {
            // Determine the type of transparency of the new buffered image
            int transparency = Transparency.OPAQUE;

            // Create the buffered image
            GraphicsDevice gs = ge.getDefaultScreenDevice();
            GraphicsConfiguration gc = gs.getDefaultConfiguration();
            bimage = gc.createCompatibleImage(
                image.getWidth(null), image.getHeight(null), transparency);
        } catch (HeadlessException e) {
            // The system does not have a screen
        }

        if (bimage == null) {
            // Create a buffered image using the default color model
            int type = BufferedImage.TYPE_INT_RGB;
            bimage = new BufferedImage(image.getWidth(null), image.getHeight(null), type);
        }

        // Copy image to buffered image
        Graphics g = bimage.createGraphics();

        // Paint the image onto the buffered image
        g.drawImage(image, 0, 0, null);
        g.dispose();

        return bimage;
    }

}
