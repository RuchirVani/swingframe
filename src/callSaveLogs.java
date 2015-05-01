import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStreamReader;
import java.sql.Savepoint;
import java.util.HashSet;

import javax.swing.JOptionPane;

import jxl.read.biff.BiffException;


public class callSaveLogs {
	
	static HashSet<String> machines= new HashSet<String>();
	
	public callSaveLogs(HashSet machines) throws BiffException, IOException
	{
		this.machines=machines;
		callFiles();
	}
	public void callFiles() throws BiffException, IOException
	{
		for (String s : machines) {
		   Accerssing_excel_file file1= new Accerssing_excel_file();
		   file1.readFile();
		   Runtime run = Runtime.getRuntime();
		   if(file1.getos(s).equals("CentOS"))
		   {
			   File dir1 = new File ("");
			   String pathBashFile=dir1.getCanonicalPath()+"\\bashFiles\\ssh.exe 172.24.201.151 -l seachange -pw SeaChange"; // bash file path
			   
			   
			   try { 
				   String[] commandArray= new String[2];
				   commandArray[0]="cmd /c start "+pathBashFile;
				   commandArray[1]="ls";
		        	Process p;
		        	p=run.exec(commandArray[0]);
		        	p=run.exec(commandArray[1]);
		        	try {
						p.waitFor();
					} catch (InterruptedException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					}
		        	 
		            BufferedReader reader = 
		                 new BufferedReader(new InputStreamReader(p.getInputStream()));
		         
		            String line = "";			
		            while ((line = reader.readLine())!= null) {
		        	System.out.println(line);
                 }
		            
		       } catch (IOException ex) {
		           
		        }
			   
		   }
		   else if(file1.getos(s).equals("Windows"))
		   {
			   System.out.println("here");
			   File dir1 = new File ("");
			   
			   String pathBatchFile=dir1.getCanonicalPath()+"\\batchFiles\\savelogs.bat"; // batch file path
			   Runtime run1 = Runtime.getRuntime();
		        try { 
		        	Process p;
		        	p=run1.exec("cmd /c start "+pathBatchFile);
		        	try {
						p.waitFor();
					} catch (InterruptedException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					}
		        	 
		            BufferedReader reader = 
		                 new BufferedReader(new InputStreamReader(p.getInputStream()));
		         
		            String line = "";			
		            while ((line = reader.readLine())!= null) {
		        	System.out.println(line);
                  }
		       } catch (IOException ex) {
		           
		        }
		   }
		}
	}

}
