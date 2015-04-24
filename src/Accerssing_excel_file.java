

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;



import java.util.HashSet;

//import javafx.scene.control.Cell;
import jxl.CellType;
import jxl.Sheet;
import jxl.Workbook;
import jxl.read.biff.BiffException;

/**
 *
 * @author rvani
 */
public class Accerssing_excel_file {

    private static ArrayList<String> allType,allLocations;
    private static ArrayList<String> diffrentTypesValues,diffrentLocationsValues;
    private static String abc;
    private static int columnNumber;
    private static File excelFile; 
    private static Workbook w;
    private static Sheet sheet; 
    public static String filePath;
    public Accerssing_excel_file() throws IOException, BiffException {
        excelFile = new File(filePath);
        System.out.println(filePath);
        w = Workbook.getWorkbook(excelFile);
        sheet= w.getSheet(0);
    }


   public static void readFile() throws IOException, BiffException {
        columnNumber=2;
        int n = sheet.getRows() - 1;
        allType = new ArrayList<String>();
        for (int i = 1; i <=n; i++) {
            if (!sheet.getCell(columnNumber, i).getContents().isEmpty())
            {
                try {
                    abc = sheet.getCell(columnNumber, i).getContents();
                    allType.add(abc);
                    } catch (Exception e) {

                }
            }
            

        }
        allLocations = new ArrayList<String>();
        for (int i = 1; i <=n; i++) {
            if (!sheet.getCell(4, i).getContents().isEmpty())
            {
                try {
                    abc = sheet.getCell(4, i).getContents();
                    allLocations.add(abc);
                    } catch (Exception e) {

                }
            }
            

        }

    }

    public static ArrayList<String> diffrentTypes() {

        diffrentTypesValues = new ArrayList<String>();
        for (int i = 0; i < allType.size(); i++) {
            if (!diffrentTypesValues.contains(allType.get(i))) {
                diffrentTypesValues.add(allType.get(i));
            }

        }
        return diffrentTypesValues;
    }

    public static ArrayList<String> diffrentLocations() {

        diffrentLocationsValues = new ArrayList<String>();
        for (int i = 0; i < allLocations.size(); i++) {
            if (!diffrentLocationsValues.contains(allLocations.get(i))) {
                diffrentLocationsValues.add(allLocations.get(i));
            }

        }
        return diffrentLocationsValues;
    }

    public static ArrayList<String> getHostName(String typeOfMachine, String selected) {
        
        ArrayList<String> combine= new ArrayList<String>();
       if(selected.equals("By Type"))
        {
        	for (int i = 0; i < sheet.getRows(); i++) {
            if(sheet.getCell(columnNumber, i).getContents().equals(typeOfMachine))
            {
                combine.add(sheet.getCell(0,i).getContents());
            }
            
        	}
        	return combine;
        }
        else if(selected.equals("By Location"))
        {
        	for (int i = 0; i < sheet.getRows(); i++) {
                if(sheet.getCell(4, i).getContents().equals(typeOfMachine))
                {
                    combine.add(sheet.getCell(0,i).getContents());
                }
                
            	}
            return combine;
        }
        
        return null;
       
    }


	public String getos(String machineName) {
		
		String OS = null;
		for (int i = 0; i < sheet.getRows(); i++) {
            if(sheet.getCell(0, i).getContents().equals(machineName))
            {
                OS=sheet.getCell(3,i).getContents();
            }
            
        }
		return OS;
		
	}

    
	
    
    
    
}
