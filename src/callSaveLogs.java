import java.io.IOException;
import java.sql.Savepoint;
import java.util.HashSet;

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
		   if(file1.getos(s).equals("CentOS"))
		   {
			   String command=""; //command with full path
			   String args="";    //Arguments for project
			   Process p = new ProcessBuilder("myCommand", "myArg").start();
		   }
		   else if(file1.getos(s).equals("Windows"))
		   {
			   String pathBatchFile=""; // batch file path
			   Runtime run = Runtime.getRuntime();
		        try { 
		            run.exec("cmd start /c "+pathBatchFile); 
		       } catch (IOException ex) {
		           
		        }
		   }
		}
	}

}
