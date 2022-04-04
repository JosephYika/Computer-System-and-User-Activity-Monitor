#!/bin/bash    

#This presents a way of writing into the log and html files. 
#Now every time I make changes here in the bash script and run sysMonitor.sh these will be applied to .log and .html files. 
#I am using here tee command which reads standard input and write to output AND FILE which is what I need 
#when I use exec command I replace my current file with a new one and I display output from this bash script in the console 
LOCATION_OF_MY_LOG_FILE=~/Documents/Assignment1_P16218862
exec > >(tee -i $LOCATION_OF_MY_LOG_FILE/sysMonitor.log)  






title="COMPUTER SYSTEM AND USER ACTIVITY MONITOR" 
CURRENT_TIME=$(date)						
CURRENT_UPDATE="Updated on $CURRENT_TIME by $USERNAME"

# This function tells us who is currently logged in on the computer 
function users
{
	
	echo "Users currently logged in are:" $USERNAME
     	echo 
}
users
	



#This function tells us when and at what time was the system boot 
function dateTime 
{
	echo
	dt=$(who -b | awk {'print $4'}) 
	echo "The last system boot was at: " $dt   
	echo
	
	
 
}
dateTime

# This tells us when the user logged in 
function loggedIn
{

	echo
	logIn=$(who | awk {'print $4'})	
	echo $USERNAME " logged in at: "$logIn
	echo

}
loggedIn

#This function will display 10 current proccesses running on the computer 
function proc
{
	echo
	echo "10 CURRENT PROCESSES RUNNING ON THE SYSTEM:" 
	echo
	ps -aux | head   #$ sign tells us to substitute the result of the enclosed command 
			 #I am not using $() here because it would print out everything in the same line 
			 # I want to display current processes running in the default format , not in one line
	
	
	
	
}
proc

function displayTopCPU 
{
	echo
	echo "TOP 5 CPU CONSUMING PROCESSES: "
	echo
	top | head -n 12 | tail -6		# - this is so that it looks nice in the console 
	echo
	echo "TOP 5 CPU CONSUMING PROCESSES:Note:I am displaying this the second time because this looks good compared to the one above." 
	echo "The first Top 5 CPU table looks good in the terminal"
	echo 
	ps -eo pid,cmd,%cpu --sort=-%cpu | head 2>> sysMonitor.log # this is so that it looks good in the sysMonitor.log file 
	
	

}
displayTopCPU 


# This function displays Top Memory Consuming Processes on the system in the log file and terminal
function topMem
{
	echo
	echo "TOP PROCESSES BY MEMORY USAGE:"
	echo
	top -b -o +%MEM | head -n 15 | tail -9 




}
topMem


# This format is used for the html table
top -b -o +%MEM | head -n 15 | tail -9 | awk {'print $1,$2,$10,$12'} > topMEM.log
sed -i '/USER/d' topMEM.log


#This function displays top memory consuming processes in a nice html table
function loopMEM
{

echo  "<tr>" 
while read pid user mem cmd; do
echo     "<td>$pid</td>"
echo    "<td>$user</td>"
echo    "<td>$mem</td>"
echo     "<td>$cmd</td>" 
echo "</tr>"
done < topMEM.log




}



# This command is  redirected to the topCPU.log so that I can use it to produce a nice table in the html 
# This will display Top 5 CPU consuming processes 
top | head -n 12 | tail -5 | awk {'print $2,$3,$10,$13'} > topCPU.log


# This function displays Top 5 Consuming Processes in a nice html table when called wihin the html body below
# I am looping through the file topCPU.log that receives  and stores top 5 consuming processes 
# Then I am just reading the data to each variable (pid1 user 1 etc ) and call these in the appropriate places within the html table
function loopText1
{

echo  "<tr>" 
while read pid1 user1 cpu1 cmd1; do
echo     "<td>$pid1</td>"
echo    "<td>$user1</td>"
echo    "<td>$cpu1</td>"
echo     "<td>$cmd1</td>" 
echo "</tr>"
done < topCPU.log

}

#This display the disk usage base on a file system and easily readable format
function diskUsage
{
	echo
	echo "DISK USAGE BASED ON THE FILE SYSTEM FORMAT:"
	echo
	df -h 
	echo
	echo "DISK SPACE INFORMATION OF THE CURRENT FILE SYSTEM:"
	echo
	df .
	echo 


}
diskUsage


#This will be used to display a nice html table with disk Usage 
df -h | awk {'print $1,$2,$3,$4,$5'} > diskUsage.log
sed -i '/Size/d' diskUsage.log


function loopUsage
{

echo  "<tr>" 
while read fileSys size used avail use; do
echo     "<td>$fileSys</td>"
echo    "<td>$size</td>"
echo    "<td>$used</td>"
echo     "<td>$avail</td>" 
echo     "<td>$use</td>" 
echo     
echo "</tr>"
done < diskUsage.log

}

#This function displays network interfaces available and their states 
function displayInterfaces 
{

   echo 
   echo "AVAILABLE NETWORK INTERFACES AND THEIR STATES:"
   echo 
   ip link show > availInter.log
   sed -i '2 a----------------------------------------------------------------------------------' availInter.log
   sed -i '6 a----------------------------------------------------------------------------------' availInter.log
   sed -i '9 a----------------------------------------------------------------------------------' availInter.log
   sed -i '12 a----------------------------------------------------------------------------------' availInter.log
   sed -i '15 a----------------------------------------------------------------------------------' availInter.log
   sed -i '18 a----------------------------------------------------------------------------------' availInter.log
   cat availInter.log
   
   
}
displayInterfaces


# This displays information about devices connected to the PCI BUS and USB BUX
function displayPU
{

	echo 
	echo "DEVICES CONNECTED TO THE PCI BUS:"
	echo
	lspci
	echo
	echo "DEVICES CONNECTED TO THE USB BUS:"
	echoS
	lsusb
	


}
displayPU


#This command writes to the file currentProc.log 
# I will use this to display all current processes running in the nice html table 
# I also want to get rid of the first line in this file so I will use sed command to to that 
ps -aux > currentProc.log
sed -i '/USER/d' currentProc.log


function loopText2
{

echo  "<tr>" 
while read user pid cpu mem vsz rss tty stat start time command; do
echo     "<td>$user</td>"
echo    "<td>$pid</td>"
echo    "<td>$cpu</td>"
echo     "<td>$mem</td>" 
echo     "<td>$vsz</td>"
echo    "<td>$rss</td>"
echo    "<td>$tty</td>"
echo     "<td>$stat</td>" 
echo    "<td>$start</td>"
echo    "<td>$time</td>"
echo     "<td>$command</td>" 
echo "</tr>"
done < currentProc.log

}

#This behaves the same way as the "exec" at the beginning of this script but instead of redirecting to .log file it redirects to the html file 
exec > >(tee -i $LOCATION_OF_MY_LOG_FILE/sysMonitor.html) 

# Declaring variables for my table in the html 
# I will call all of these variables and create a nice presentable table about the Operating System Details 
system_version=$(lsb_release -a | tail -2 | head -1 | awk {'print $2'})
system_name=$(uname -o)
proc_type=$(uname -p)
hard_platform=$(uname -i)
hard_name=$(uname -m)
up_time=$(uptime -p | cut -d " " -f 2,3,4,5)



echo " "

# HTML Report - this needs to overwrite sysMonitor.html file so that .html can be updated and opened in the browser 

cat <<- _EOF_ 
<!DOCTYPE html>
<html>
 <head> 
  <title>$title</title>
  <style>
  
  
   html, body{
   
   	margin: 0;
   	padding: 0;
   }
  
  
   .myClass h1 {
   	 background-image: url('wp2972537.jpg');
  	 text-align: center; 
  	 color: white;
   	 background-size: cover;
   	 font-size: 1cm;
   	 
   }
   
   
   .standardInfo{
   	text-align:center;
   	color: #000000;
   	font-weight: bold;
   	font-size: 0.5cm;
   	
   	
   	
   }
   .content-table {
	  border-collapse: collapse;
	  margin: 25x 0;
	  font-size: 0.5cm;
	  min-width: 400;
	  margin-left: auto;
  	  margin-right: auto;
  	  margin-top: 20px;
  	  
	  
	}
   .content-table thead tr {
   	background-color: MediumSeaGreen; 	
   	text-align: left;
   	font-weight: bold;
   	}
   
   
   
   .content-table th,
   .content-table td {
   	padding: 12px 15px;
   	border: 1px solid #000;
   	border-collapse: collapse;
   
   }
   
   .content-table caption {
    	font-weight: bold;
    	font-size: 0.6cm;
   }
   
   
   .second-table {
   	  border-collapse: collapse;
	  margin: 25x 0;
	  font-size: 0.5cm;
	  min-width: 400;
	  margin-left: auto;
	  margin-right: auto;
  	  margin-top: 40px;
  	  
  	  
  	  
  	  
   }
   
   
   .second-table thead tr {
   	background-color: MediumSeaGreen; 	
   	text-align: left;
   	font-weight: bold;
   	
   	
   	}
   
   
   .second-table th,
   .second-table td {
   	padding: 12px 15px;
   	border: 1px solid #000;
   	border-collapse: collapse;
   	
  	
   
   }
   
   .second-table caption{
   	font-weight: bold;
    	font-size: 0.6cm;
   
   }
  
   
   .third-table{
   
   	  border-collapse: collapse;
	  
	  font-size: 0.3cm;
	  margin-left: auto;
	  margin-right: auto;
  	  
  	  
  	  width: 400px;
  	  margin-top: 3px;
   
   }
   .myDiv {
   
     width: 800px;
     height: 400px;
     margin-left: 90px;
     overflow-y:auto;
     margin-top:0px;
     margin-left:auto;
     margin-right:auto;
     
     
   }
   
   .third-table th{  	
   	background-color: MediumSeaGreen; 	
   	text-align: left;
   	font-weight: bold; 
   	position: sticky;
   	top: 0;
   	
  	
   }
   .third-table th,td {
   	padding: 10px;
   	border: 1px solid #000;
   	border-collapse: collapse;
   
   }
   .tableInfo{
   
   	text-align:center;
   	margin-top:50px;
   	font-weight: bold;
    	font-size: 0.6cm;
   	
   }
   
   
   

   
   
  
  
  
 </style>  
 </head>
	
	
 <body>
 <div class="myClass">
  <h1>$title</h1>
  <p class="standardInfo">$CURRENT_UPDATE</p>
  <p class="standardInfo">$(dateTime)</p>
  <p class="standardInfo">$(users)</p>
  <p class="standardInfo">$(loggedIn)</p>
  </div>
  
<div class="myClass2"> 
  <h2></h2>

  <table class="content-table">
  <caption>Operating-System Details</caption>
  <thead>
    <tr>
      <th>Version</th>
      <th>Name</th>
      <th>Processor Type</th>
      <th>Hardware Platform</th>
      <th>Hardware Name</th>
      <th>Up Time</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>$system_version</td>
      <td>$system_name</td>
      <td>$proc_type</td>
      <td>$hard_platform</td>
      <td>$hard_name</td>
      <td>$up_time</td>
      
     </tr> 
  </tbody>
</table>



  <table class="second-table">
  <caption>Top 5 CPU Consuming Processes</caption>
  <thead>
    <tr>
      <th>PID</th>
      <th>USER</th>
      <th>%CPU</th>
      <th>COMMAND</th>
    </tr>
  </thead>
  <tbody>
   $(loopText1)
      
  </tbody>
</table> 


<table class="second-table">
  <caption>Top Processes by Memory Usage</caption>
  <thead>
    <tr>
      <th>PID</th>
      <th>USER</th>
      <th>%MEM</th>
      <th>COMMAND</th>
    </tr>
  </thead>
  <tbody>
   $(loopMEM)
      
  </tbody>
</table>




<table class="second-table">
  <caption>Disk Usage</caption>
  <thead>
    <tr>
      <th>File System</th>
      <th>Size</th>
      <th>Used</th>
      <th>Available</th>
      <th>Use%</th>
      
    </tr>
  </thead>
  <tbody>
   $(loopUsage)
      
  </tbody>
</table>

<p class="tableInfo" >Current Processes Running</p>
<div class="myDiv">
<table class="third-table"> 

  <thead>
    <tr>
      <th>USER</th>
      <th>PID</th>
      <th>%CPU</th>
      <th>%MEM</th>
      <th>VSZ</th>
      <th>RSS</th>
      <th>TTY</th>
      <th>STAT</th>
      <th>START</th>
      <th>TIME</th>
      <th>COMMAND</th>
      
    </tr>
  </thead>
  <tbody>
   $(loopText2)
      
  </tbody>
</table>
</div>
</div>  
   
  
 </body>
</html>
_EOF_













