import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.ItemEvent;
import java.awt.event.ItemListener;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.concurrent.BrokenBarrierException;

import javax.swing.*;

import jxl.read.biff.BiffException;
import jxl.read.biff.File;

/**
*
* @author rvani
*/
public class StartActivity implements ItemListener,ActionListener {
	
	
	static Accerssing_excel_file file1;
	 static JPanel hostnamePanel;
	 static JPanel Panel2;
	 static JFrame contentFrame;
	 static JPanel osPanel;
	 static JPanel locationPanel;
	 static JPanel Panel4;
	 static JPanel Panel5;
	 static JButton button1;
	 static JScrollPane p2;
	 static ArrayList<String> hostNames;
	 static JCheckBox c1,c4;
	 static JLabel osLable;
	 static JPanel outterPanel5,outterPanel1,outterPanel2,outterPanel4,Panel6;
	 static  String selected;
	 static HashSet selectedMahines;
	 
	 public static void main(String[] args) throws BiffException, IOException {
	
		 new chooseFile();
		 selectedMahines=new HashSet<String>();
	      contentFrame= new JFrame("LOG COLLECTOR:");	
	      contentFrame.setLayout(new GridLayout(4,1));
	      JMenuBar menubar= new JMenuBar();
	      JMenu menu=new JMenu("Options");
	      JMenuItem byType=new JMenuItem("By Type");
	      byType.addActionListener(new StartActivity());
	      menu.add(byType);
	      JMenuItem byLocation=new JMenuItem("By Location");
	      byLocation.addActionListener(new StartActivity());
	      menu.add(byLocation);
	      
	      menubar.add(menu);
	      contentFrame.setJMenuBar(menubar);
	      hostNames= new ArrayList<String>();
	      // reading from file
	      file1 = new Accerssing_excel_file();
	      file1.readFile();

//-------------------------------------------------------------------------------------------------------//	      
	      JPanel typePanel= new JPanel();
	      typePanel.setLayout(new GridLayout(file1.diffrentTypes().size(),1));
	      JPanel Panel1 = new JPanel(new GridLayout(1,3));
	      //JPanel Panel1 = new JPanel(new FlowLayout(FlowLayout.LEFT,50,10));
	      JCheckBox c = new JCheckBox();
	      Panel1.add(new JLabel("Type:"));
	      
	      for(int i=0; i<file1.diffrentTypes().size();i++)
	      {
	    	  c = new JCheckBox(file1.diffrentTypes().get(i));
	    	  c.addItemListener(new StartActivity());
	    	  typePanel.add(c);
	      }
	      JScrollPane p1= new JScrollPane(typePanel);
	      p1.setVerticalScrollBarPolicy(ScrollPaneConstants.VERTICAL_SCROLLBAR_ALWAYS);
	      Panel1.add(p1);
	      JPanel tp= new JPanel();
	      Panel1.add(tp);
	      Panel1.setBorder(BorderFactory.createEmptyBorder(10,50,10,50));
	      outterPanel1 = new JPanel(new GridLayout(1,1));
	      outterPanel1.add(Panel1);
	      outterPanel1.setBorder(BorderFactory.createLineBorder(Color.black));
	      
//------------------------------------------------------------------------------------------------------------------//
	      locationPanel= new JPanel();
	      //
	      locationPanel.setLayout(new GridLayout(file1.diffrentLocations().size(),1));
	      JPanel Panel5 = new JPanel(new GridLayout(1,3));
	      //JPanel Panel1 = new JPanel(new FlowLayout(FlowLayout.LEFT,50,10));
	      JCheckBox c2 = new JCheckBox();
	      Panel5.add(new JLabel("Locations:"));
	      
	      for(int i=0; i<file1.diffrentLocations().size();i++)
	      {
	    	  c2 = new JCheckBox(file1.diffrentLocations().get(i));
	    	  c2.addItemListener(new StartActivity());
	    	  locationPanel.add(c2);
	      }
	      JScrollPane p2= new JScrollPane(locationPanel);
	      p2.setVerticalScrollBarPolicy(ScrollPaneConstants.VERTICAL_SCROLLBAR_ALWAYS);
	      Panel5.add(p2);
	      JPanel tp2= new JPanel();
	      Panel5.add(tp2);
	      Panel5.setBorder(BorderFactory.createEmptyBorder(10,50,10,50));
	      outterPanel5 = new JPanel(new GridLayout(1,1));
	      outterPanel5.add(Panel5);
	      outterPanel5.setBorder(BorderFactory.createLineBorder(Color.black));
	      
//------------------------------------------------------------------------------------------------------------------------// 
	      c1 = new JCheckBox();
		  Panel2 = new JPanel(new GridLayout(1,2));
	      Panel2.add(new JLabel("Hostname:"));
	      hostnamePanel= new JPanel();
	      hostnamePanel.setLayout(new GridLayout(hostNames.size(),1));
	      p2= new JScrollPane(hostnamePanel);
	      p2.setVerticalScrollBarPolicy(ScrollPaneConstants.VERTICAL_SCROLLBAR_ALWAYS);
	      Panel2.add(p2);
	      JPanel tp1= new JPanel();
	      Panel2.add(tp1);
	      Panel2.setBorder(BorderFactory.createEmptyBorder(10,50,10,50));
	      outterPanel2 = new JPanel(new GridLayout(1,1));
	      outterPanel2.add(Panel2);
	      outterPanel2.setBorder(BorderFactory.createLineBorder(Color.black));
	      
	      
//------------------------------------------------------------------------------------------------------------------------//	      
	      	      
	      osPanel= new JPanel();
	      Panel4 = new JPanel(new FlowLayout(FlowLayout.LEFT));
	      Panel4.add(new JLabel("Os:"));
	      Panel4.setBorder(BorderFactory.createEmptyBorder(10,50,10,50));
	      outterPanel4 = new JPanel(new GridLayout(1,1));
	      outterPanel4.add(Panel4);
	      outterPanel4.setBorder(BorderFactory.createLineBorder(Color.black));
	     
	      
 //------------------------------------------------------------------------------------------------------------------------//	      
	     
	      
	      
	      button1 = new JButton("Submit");
	      button1.addActionListener(new ActionListener() {
			
			@Override
			public void actionPerformed(ActionEvent e) {
				try {
					new callSaveLogs(selectedMahines);
				} catch (BiffException | IOException e1) {
					// TODO Auto-generated catch block
					e1.printStackTrace();
				}
				
			}
		});
	      Panel6= new JPanel();
	      Panel6.add(button1);
	      Panel6.setBorder(BorderFactory.createLineBorder(Color.black));

			contentFrame.setVisible(true);
			contentFrame.setSize(400, 600);
			contentFrame.setLocationRelativeTo(null);
			contentFrame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);

	      
	      
	      }

	@Override
	public void itemStateChanged(ItemEvent e) {
		Object source = e.getItemSelectable();
		
		if(e.getStateChange()==2){
		removeElements(e.paramString().split("text=")[1].split("]")[0]);
		}
		else if(e.getStateChange()==1)
		{
			updateHostPanel(e.paramString().split("text=")[1].split("]")[0]);
		}
		
		
	}

	private void removeElements(String type) {
		
		for(int i=0; i<file1.getHostName(type,selected).size();i++)
	      {
			if(hostNames.contains(file1.getHostName(type,selected).get(i)))
			{
				hostNames.remove(file1.getHostName(type,selected).get(i));
			}
	    	   
	      }
		hostnamePanel.removeAll();
		c4= new JCheckBox("Select All");
		c4.addItemListener(new ItemListener() {
			
			@Override
			public void itemStateChanged(ItemEvent e) {
				
				if (e.getStateChange()==1)
				{
					  for(int h=0;h<selectedMahines.size();h++)
				  	  {
				  		selectedMahines.remove(selectedMahines);
				  	  }
					 
					
					hostnamePanel.removeAll();
					hostnamePanel.add(c4);
					
					for (int j=0; j<hostNames.size();j++)
					  {
						      
						  	  c1= new JCheckBox(hostNames.get(j));
						  	  c1.setSelected(true);
						  	  hostnamePanel.add(c1);
						  	  
						  	  selectedMahines.add(hostNames.get(j));
						  	  
						  	  
						  	 
						  	  
					  }
					
					contentFrame.revalidate();
				}
				else if(e.getStateChange()==2)
				{
					hostnamePanel.removeAll();
					hostnamePanel.add(c4);
					for (int j=0; j<hostNames.size();j++)
					  {
						      
						  	  c1= new JCheckBox(hostNames.get(j));
						  	  hostnamePanel.add(c1);
						  	  for(int h=0;h<selectedMahines.size();h++)
						  	  {
						  		selectedMahines.remove(selectedMahines);
						  	  }
						  	
						  	 
						  	  
					  }
					
					contentFrame.revalidate();
					
				}
					
			}
		});
		hostnamePanel.add(c4);
		  for (int j=0; j<hostNames.size();j++)
		  {
			  	  c1= new JCheckBox(hostNames.get(j));
					  c1.addItemListener(new ItemListener() {
						
						@Override
						public void itemStateChanged(ItemEvent e) {
							
							if (e.getStateChange()==1)
							{
								String machineName=e.paramString().split("text=")[1].split("]")[0];
								osLable=new JLabel(file1.getos(machineName));
								Panel4.add(osLable);
								selectedMahines.add(machineName);
								contentFrame.revalidate();
							}
							else if(e.getStateChange()==2)
							{
								String machineName=e.paramString().split("text=")[1].split("]")[0];
								selectedMahines.remove(machineName);
								osLable.setText("");
								contentFrame.revalidate();
							}
								
						}
					});
					  hostnamePanel.add(c1);
			  
			 
			  
			  
		  }
		  contentFrame.revalidate();
		 
	}

	private void updateHostPanel(String type) {
		
		
		 for(int i=0; i<file1.getHostName(type,selected).size();i++)
	      {
			 if(! hostNames.contains(file1.getHostName(type,selected).get(i)))
	    	 {
	    		 hostNames.add(file1.getHostName(type,selected).get(i));
	    	 }
			
	    	  
	      }
		 hostnamePanel.removeAll();
		 c4= new JCheckBox("Select All");
			c4.addItemListener(new ItemListener() {
				
				@Override
				public void itemStateChanged(ItemEvent e) {
					
					if (e.getStateChange()==1)
					{
						
						hostnamePanel.removeAll();
						hostnamePanel.add(c4);
						  for(int h=0;h<selectedMahines.size();h++)
					  	  {
					  		selectedMahines.remove(selectedMahines);
					  	  }
						
						for (int j=0; j<hostNames.size();j++)
						  {
							      
							  	  c1= new JCheckBox(hostNames.get(j));
							  	  c1.setSelected(true);
							  	  hostnamePanel.add(c1);
							  	selectedMahines.add(hostNames.get(j));
							  	 
							  	  
						  }
						contentFrame.revalidate();
						
					}
					else if(e.getStateChange()==2)
					{
						hostnamePanel.removeAll();
						hostnamePanel.add(c4);
						for (int j=0; j<hostNames.size();j++)
						  {
							      
							  	  c1= new JCheckBox(hostNames.get(j));
							  	  hostnamePanel.add(c1);
							  	  for(int h=0;h<selectedMahines.size();h++)
							  	  {
							  		selectedMahines.remove(selectedMahines);
							  	  }
							  	
							  	 
							  	  
						  }
						contentFrame.revalidate();
						
						
					}
						
				}
			});
			hostnamePanel.add(c4);
			
		  for (int j=0; j<hostNames.size();j++)
		  {
			  	  c1= new JCheckBox(hostNames.get(j));
			  	c1.addItemListener(new ItemListener() {
					
					@Override
					public void itemStateChanged(ItemEvent e) {
						if (e.getStateChange()==1)
						{
							String machineName=e.paramString().split("text=")[1].split("]")[0];
							osLable=new JLabel(file1.getos(machineName));
							Panel4.add(osLable);
							selectedMahines.add(machineName);
							contentFrame.revalidate();
							
						}
						else if(e.getStateChange()==2)
						{
							osLable.setText("");
							String machineName=e.paramString().split("text=")[1].split("]")[0];
							selectedMahines.remove(machineName);
							contentFrame.revalidate();
							
						}
						
					}
				});
					  hostnamePanel.add(c1);
			  
			  contentFrame.revalidate();
			 
			  
		  }
		  
		 
		}

	@SuppressWarnings("deprecation")
	@Override
	public void actionPerformed(ActionEvent e) {
		
		selected=e.getActionCommand();
		if(selected.equals("By Type"))
		{
			contentFrame.remove(outterPanel5);
			contentFrame.revalidate();
			contentFrame.add(outterPanel1);
			 contentFrame.add(outterPanel2);
			 contentFrame.add(outterPanel4);
			 contentFrame.add(Panel6);
			//contentFrame.remove(outterPanel5);
			contentFrame.revalidate();
		}
		else if (selected.equals("By Location"))
		{
			contentFrame.remove(outterPanel1);
			contentFrame.revalidate();
			contentFrame.add(outterPanel5);
			 contentFrame.add(outterPanel2);
			 contentFrame.add(outterPanel4);
			 contentFrame.add(Panel6);
			contentFrame.revalidate();
			
		}
		
	}

}




