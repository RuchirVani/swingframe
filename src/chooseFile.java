import java.io.IOException;

import javax.swing.JFileChooser;
import javax.swing.JFrame;
import javax.swing.JOptionPane;

import jxl.read.biff.BiffException;


public class chooseFile extends JFrame{

	static String selectedFile;
	public chooseFile() {
		try
		{
			JFileChooser fileChooser = new JFileChooser("Select File");
			int returnValue = fileChooser.showOpenDialog(null);
	        if (returnValue == JFileChooser.APPROVE_OPTION) {
	           selectedFile= fileChooser.getSelectedFile().toString();
	           if(!selectedFile.split("\\.")[1].equals("xls"))
	          {
	        	  JOptionPane.showMessageDialog(this,
	        			    "File should be .xls format only!!",
	        			    "Inane error",
	        			    JOptionPane.ERROR_MESSAGE);
	        	  new chooseFile();
	          }
	           Accerssing_excel_file.filePath=selectedFile;
	        }
	        else if (returnValue != JFileChooser.APPROVE_OPTION)
	        {
	        JOptionPane.showMessageDialog(this,
     			    "You didnt select anything!!",
     			    "Inane error",
     			    JOptionPane.ERROR_MESSAGE);
			
	    	 		System.exit(ERROR);
	        }
	        	
		}
	     catch (Exception e) {
	    	
	    	 
		}
		  
        
	}

}
