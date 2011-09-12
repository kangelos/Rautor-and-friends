/*
 * RautorViewerAboutBox.java
 * Copyright (c) 2009, Angelos Karageorgiou All rights reserved.

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
import org.jdesktop.application.View;
import javax.swing.KeyStroke;
import java.awt.event.*;
import java.awt.Color;
import javax.swing.JComponent;
import javax.swing.text.DefaultHighlighter;
import javax.swing.text.Highlighter;
import javax.swing.JDialog;
import javax.swing.JFrame;
import java.util.regex.*;
import javax.swing.JFileChooser;
import javax.swing.Timer;
import java.io.*;



public class TextBox extends javax.swing.JDialog {
    int LastFoundIndex=0;
    String SearchText="";
    Timer messageTimer;

    public TextBox(java.awt.Frame parent,String Contents,int start,int end) {
        super(parent);
        initComponents();

        if ( Contents==null) {
            return;
        }
        jTextArea1.setText(Contents);        
        Highlighter h=jTextArea1.getHighlighter();

        if ( ( start != 0) && ( end != 0 ) ) {            
            HighLight(Contents,h,start,end);
            jTextArea1.setCaretPosition(start);
        }
        
        KeyStroke stroke = KeyStroke.getKeyStroke(KeyEvent.VK_ESCAPE, 0);
        rootPane.registerKeyboardAction(actionListener, stroke, JComponent.WHEN_IN_FOCUSED_WINDOW);
        // status bar initialization - message timeout, idle icon and busy animation, etc

        messageTimer = new Timer(5, new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                try {Thread.sleep(1500);} catch (Exception myex) {;}
                jLabel1.setText("");
            }
        });       
    }

    //   ***********************************************************

    void HighLight(String Contents,Highlighter h,int start,int end){
        h.removeAllHighlights();        
        try {               
                h.addHighlight(start, end,DefaultHighlighter.DefaultPainter);
        } catch (Exception ignore) {}
    }


   //   ***********************************************************
    @Action public void closeAboutBox() {
        dispose();
    }


    //   ***********************************************************
 ActionListener actionListener = new ActionListener() {
        @Override
  public void actionPerformed(ActionEvent actionEvent) {
     dispose();
  }
};


@Action
    public void OpenSearchTextBox() {
    JDialog SearchtextBoxDialog;

        JFrame mainFrame = MultiViewerApp.getApplication().getMainFrame();
        SearchtextBoxDialog =new SearchTextBox(mainFrame,true);
        SearchtextBoxDialog.setLocationRelativeTo(mainFrame);
        SearchtextBoxDialog.setTitle("Find");
        MultiViewerApp.getApplication().show(SearchtextBoxDialog);

        SearchText=SearchTextBox.getTextField();
        if ( SearchText != null) {
            LastFoundIndex=0;
            LookFor(SearchText,jTextArea1.getText());
        }
    }


@Action
public void Lookagain(){
    //LastFoundIndex++;
    LookFor(SearchText, jTextArea1.getText());
}

private void LookFor(String SearchText,String ScreenContents){
    int HighlStart=0;
    int HighlEnd=0;
    
        if ((SearchText==null) || ( ScreenContents==null)){
            return;
        }
        if ( (SearchText.length()<=0) || (ScreenContents.length()<=0)){
            return;
        }

        if ( ScreenContents.contains(SearchText) )  {                                
                HighlStart=ScreenContents.indexOf (SearchText,LastFoundIndex);
                HighlEnd=HighlStart+SearchText.length();                           
        } else {
            Pattern mypattern;
            try {
                mypattern=Pattern.compile(SearchText, Pattern.CASE_INSENSITIVE | Pattern.DOTALL | Pattern.MULTILINE) ;
            } catch (PatternSyntaxException ignore) {                
                return;
            }

           Matcher match=mypattern.matcher(ScreenContents);

           /* get only the first match */
           if  (match.find(LastFoundIndex) ){
               HighlStart=match.start();
               HighlEnd=match.end();                
           }
         }

         // we got everything
         Highlighter h=jTextArea1.getHighlighter();
        if ( ( HighlStart > 0) && ( HighlEnd > 0 ) ) {
            LastFoundIndex=HighlEnd;
            HighLight(ScreenContents,h,HighlStart,HighlEnd);
            jTextArea1.setCaretPosition(HighlStart);
        }
}
    /** This method is called from within the constructor to
     * initialize the form.
     * WARNING: Do NOT modify this code. The content of this method is
     * always regenerated by the Form Editor.
     */
    // <editor-fold defaultstate="collapsed" desc="Generated Code">//GEN-BEGIN:initComponents
    private void initComponents() {

        jScrollPane1 = new javax.swing.JScrollPane();
        jTextPane1 = new javax.swing.JTextPane();
        jScrollPane3 = new javax.swing.JScrollPane();
        jTextArea1 = new javax.swing.JTextArea();
        jLabel1 = new javax.swing.JLabel();
        jMenuBar1 = new javax.swing.JMenuBar();
        jMenu1 = new javax.swing.JMenu();
        jMenuItem4 = new javax.swing.JMenuItem();
        jMenuItem1 = new javax.swing.JMenuItem();
        jMenu2 = new javax.swing.JMenu();
        jMenuItem2 = new javax.swing.JMenuItem();
        jMenuItem3 = new javax.swing.JMenuItem();

        jScrollPane1.setName("jScrollPane1"); // NOI18N

        jTextPane1.setName("jTextPane1"); // NOI18N
        jScrollPane1.setViewportView(jTextPane1);

        setDefaultCloseOperation(javax.swing.WindowConstants.DISPOSE_ON_CLOSE);
        org.jdesktop.application.ResourceMap resourceMap = org.jdesktop.application.Application.getInstance(MultiViewer.MultiViewerApp.class).getContext().getResourceMap(TextBox.class);
        setTitle(resourceMap.getString("title")); // NOI18N
        setModal(true);
        setName("aboutBox"); // NOI18N

        jScrollPane3.setName("jScrollPane3"); // NOI18N

        jTextArea1.setColumns(20);
        jTextArea1.setEditable(false);
        jTextArea1.setFont(new java.awt.Font("Arial Unicode MS", 0, 12)); // NOI18N
        jTextArea1.setRows(5);
        jTextArea1.setName("jTextArea1"); // NOI18N
        jTextArea1.setSelectionColor(resourceMap.getColor("jTextArea1.selectionColor")); // NOI18N
        jScrollPane3.setViewportView(jTextArea1);

        jLabel1.setText(resourceMap.getString("jLabel1.text")); // NOI18N
        jLabel1.setName("jLabel1"); // NOI18N

        jMenuBar1.setName("jMenuBar1"); // NOI18N

        jMenu1.setText(resourceMap.getString("jMenu1.text")); // NOI18N
        jMenu1.setName("jMenu1"); // NOI18N

        javax.swing.ActionMap actionMap = org.jdesktop.application.Application.getInstance(MultiViewer.MultiViewerApp.class).getContext().getActionMap(TextBox.class, this);
        jMenuItem4.setAction(actionMap.get("SaveAs")); // NOI18N
        jMenuItem4.setText(resourceMap.getString("jMenuItem4.text")); // NOI18N
        jMenuItem4.setName("jMenuItem4"); // NOI18N
        jMenu1.add(jMenuItem4);

        jMenuItem1.setAction(actionMap.get("CloseTextBox")); // NOI18N
        jMenuItem1.setText(resourceMap.getString("jMenuItem1.text")); // NOI18N
        jMenuItem1.setName("jMenuItem1"); // NOI18N
        jMenu1.add(jMenuItem1);

        jMenuBar1.add(jMenu1);

        jMenu2.setText(resourceMap.getString("jMenu2.text")); // NOI18N
        jMenu2.setName("jMenu2"); // NOI18N

        jMenuItem2.setAction(actionMap.get("OpenSearchTextBox")); // NOI18N
        jMenuItem2.setText(resourceMap.getString("jMenuItem2.text")); // NOI18N
        jMenuItem2.setName("jMenuItem2"); // NOI18N
        jMenu2.add(jMenuItem2);

        jMenuItem3.setAction(actionMap.get("Lookagain")); // NOI18N
        jMenuItem3.setText(resourceMap.getString("jMenuItem3.text")); // NOI18N
        jMenuItem3.setName("jMenuItem3"); // NOI18N
        jMenu2.add(jMenuItem3);

        jMenuBar1.add(jMenu2);

        setJMenuBar(jMenuBar1);

        javax.swing.GroupLayout layout = new javax.swing.GroupLayout(getContentPane());
        getContentPane().setLayout(layout);
        layout.setHorizontalGroup(
            layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addComponent(jLabel1, javax.swing.GroupLayout.DEFAULT_SIZE, 410, Short.MAX_VALUE)
            .addComponent(jScrollPane3, javax.swing.GroupLayout.DEFAULT_SIZE, 410, Short.MAX_VALUE)
        );
        layout.setVerticalGroup(
            layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, layout.createSequentialGroup()
                .addComponent(jScrollPane3, javax.swing.GroupLayout.DEFAULT_SIZE, 466, Short.MAX_VALUE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(jLabel1, javax.swing.GroupLayout.PREFERRED_SIZE, 17, javax.swing.GroupLayout.PREFERRED_SIZE))
        );

        pack();
    }// </editor-fold>//GEN-END:initComponents

    @Action
    public void CloseTextBox() {
        dispose();
    }

    @Action
    public void SaveAs() {
        SecurityManager backup = System.getSecurityManager();
        System.setSecurityManager(null);

        JFileChooser fc = new JFileChooser();
//        fc.setFileSelectionMode(JFileChooser.FILES_AND_DIRECTORIES);
        fc.setFileSelectionMode(JFileChooser.FILES_ONLY);
        fc.setDialogType(JFileChooser.SAVE_DIALOG);
        fc.setDialogTitle("Save Text to file");


        int returnVal = fc.showSaveDialog(jScrollPane1);
        if (returnVal != JFileChooser.APPROVE_OPTION) {
            System.setSecurityManager(backup);
            return;
        }
        File textfile = fc.getSelectedFile();
        try {
            BufferedWriter outfile= new BufferedWriter(new FileWriter(textfile));
            outfile.write(jTextArea1.getText());
            outfile.close();
        } catch ( Exception e) {
            jLabel1.setText(e.getLocalizedMessage());
            messageTimer.start();
        }
        jLabel1.setText("Saved File:"+textfile.toString());
        // messageTimer.start();
        System.setSecurityManager(backup);
    }

    // Variables declaration - do not modify//GEN-BEGIN:variables
    private javax.swing.JLabel jLabel1;
    private javax.swing.JMenu jMenu1;
    private javax.swing.JMenu jMenu2;
    private javax.swing.JMenuBar jMenuBar1;
    private javax.swing.JMenuItem jMenuItem1;
    private javax.swing.JMenuItem jMenuItem2;
    private javax.swing.JMenuItem jMenuItem3;
    private javax.swing.JMenuItem jMenuItem4;
    private javax.swing.JScrollPane jScrollPane1;
    private javax.swing.JScrollPane jScrollPane3;
    private javax.swing.JTextArea jTextArea1;
    private javax.swing.JTextPane jTextPane1;
    // End of variables declaration//GEN-END:variables
    
}
class MyHighlightPainter extends DefaultHighlighter.DefaultHighlightPainter {
   public MyHighlightPainter(Color color) {
      super(color);
   }
}
