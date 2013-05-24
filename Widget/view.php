<html>
<head>
<style type="text/css">
.tooltip-wrap {
  position: relative;
}
.tooltip-wrap .tooltip-content {
  display: none;
  position: absolute;
  top: 15%;
  left: 5%;
  right: 5%;
  background-color: #F0F0F0;
  padding: .5em;
}
.tooltip-wrap:active .tooltip-content {
  display: block;
}

.image-lnu {
 position: absolute;
 top: 85%;
 left: 85%;
}
</style>
</head>
<body>

<!-- Information to the viewer -->
<p>This widget is used to add new hosts and to add services to new and / or existing nodes.
<br><br>
<div class="image-lnu">
<img src="http://monitor.rosi.local/lnu.jpeg" />
</div>
<div class="tooltip-wrap">
  <img src="http://monitor.rosi.local/question.jpg" alt="Some Image" width="35" height="35" />
 <div class="tooltip-content">
    <p> Example file:<br><br>
        linuxnode1.example.com<br>
        linuxnode2.example.com<br>
        linuxserver.example.com<br>
        <br>
(.txt and no larger than 20 KB)
</p>
  </div>
</div>

<!-- Upload hostname and checks files -->
<form action="" method="post"
        enctype="multipart/form-data">
        <label for="hostname">Hostnames:</label><br>
        <input type="file" name="hostname" id="hostname"><br>

        <div class="tooltip-wrap">
  <img src="http://monitor.rosi.local/question.jpg" alt="Some Image" width="35" height="35" />
  <div class="tooltip-content">
    <p> <p>Example file:<br><br>
        command[users]=/opt/plugins/check_users -w 5 -c 10<br>
        command[load]=/opt/plugins/check_load -w 15,10,5 -c 30,25,20<br>
        command[swap]=/opt/plugins/check_swap -w 20% -c 10%<br>
        <br>
        (.txt and no larger than 20 KB)<br>
        <br>
   </p>
  </div>
</div>
        <label for="service">Add and/or change service:</label><br>
        <input type="file" name="service" id="service"><br>

        <div class="tooltip-wrap">
  <img src="http://monitor.rosi.local/question.jpg" alt="Some Image" width="35" height="35" />
  <div class="tooltip-content">
    <p>Choose the script file to be uploaded. The script's command should be included in the file above.<br>
        <br>
        (Script files and no larger than 20KB)
   </p>
  </div>
</div>
        <label for="script">Upload new script(opt):</label><br>
        <input type="file" name="script" id="script"><br>


<p> Please note that the change may take up 7-8 minutes to complete.</p>

<input type="submit" name="submit" value="Submit">
<br>

<?php
error_reporting (E_ALL ^ E_NOTICE);
if (isset($_POST['submit'])){
//Hostname begins
        if ((($_FILES["hostname"]["type"] == "text/plain") && ($_FILES["hostname"]["size"]< 20000))){
                if ($_FILES["hostname"]["error"] > 0) {
                        echo "Error: " . $_FILES["hostname"]["error"] . "<br>";

                }
                else {
                        echo "Upload: " . $_FILES["hostname"]["name"] . "<br>";
                        echo "Stored in: " . ($_FILES["hostname"]['/mnt/upload/']);
                        }
                if (file_exists("/mnt/upload/" . $_FILES["hostname"]["name"])) {
                        echo $_FILES["hostname"]["name"] . " already exists." . "<br>";
                }
                else {
                        move_uploaded_file($_FILES["hostname"]["tmp_name"],
                        "/mnt/upload/" . $_FILES["hostname"]["name"]);
                        echo "Stored in: " . "/mnt/upload/" . $_FILES["hostname"]["name"] . "<br>";
                        }
        }
        else {
                echo "Invalid file" . "<br>";
        }

//Service begins
        if ((($_FILES["service"]["type"] == "text/plain") && ($_FILES["service"]["size"]< 20000))){
                if ($_FILES["service"]["error"] > 0) {
                        echo "Error: " . $_FILES["service"]["error"] . "<br>";
                }
                else {
                        echo "Upload: " . $_FILES["service"]["name"] . "<br>";
                        echo "Stored in: " . ($_FILES["service"]['/mnt/upload/']);
                }
                if (file_exists("/mnt/upload/" . $_FILES["service"]["name"])) {
                        echo $_FILES["service"]["name"] . " already exists. " . "<br>";
                }
                else {
                        move_uploaded_file($_FILES["service"]["tmp_name"],
                        "/mnt/upload/" . $_FILES["service"]["name"]);
                        echo "Stored in: " . "/mnt/upload/" . $_FILES["service"]["name"] . "<br>";
                }
        }
        else {
                echo "Invalid file" . "<br>";
        }

//Script begins
        if ((($_FILES["script"]["type"] == "application/octet-stream"))
                && ($_FILES["script"]["size"]< 20000)){

                if ($_FILES["script"]["error"] > 0) {
                        echo "Error: " . $_FILES["script"]["error"] . "<br>";
                }
                else {
                        echo "Upload: " . $_FILES["script"]["name"] . "<br>";
                        echo "Stored in: " . ($_FILES["script"]['/mnt/scripts/']);
                }
                if (file_exists("/mnt/scripts/" . $_FILES["script"]["name"])) {
                        echo $_FILES["script"]["name"] . " already exists. " . "<br>";
                }
                else {
                        move_uploaded_file($_FILES["script"]["tmp_name"],
                        "/mnt/scripts/" . $_FILES["script"]["name"]);
                        echo "Stored in: " . "/mnt/scripts/" . $_FILES["script"]["name"] . "<br>";
                }
        }
        else {
                echo "Invalid file" . "<br>";
        }
}

echo "For progress, update the page:" . "<br>";
$filestring = file_get_contents('/mnt/done.txt');
echo nl2br( htmlspecialchars($filestring) );

?>

</form>

<br>
<br>
&copy; Simon Blixt & Robin Jonsson.
</body>
</html>