<?php
//图片下载代理，在防盗链的情况下使用
function get_img_type($data) {
  $magics = array(
    'ffd8ff' => 'jpg',
    '89504e470d0a1a0a' => 'png',
    '474946383761' => 'gif',
    '474946383961' => 'gif',
  );

  foreach ($magics as $str => $ext) {
    if (strtolower(bin2hex(substr($data, 0, strlen($str)/2))) == $str) return $ext;
  }

  return NULL;
}
if(!empty($_GET['img']))
{
  $opts = array('http' =>
    array(
      'method'  => 'GET',
      'header'  => 'Referer: '.$_GET['ref'],
    )
  );

  $context  = stream_context_create($opts);

  $image = file_get_contents($_GET['img'], false, $context);
  if($image !== false)
  {
    $imgData = get_img_type($image);
    if(!empty($imgData))
    {
      header('Content-Type: ' . $imgData);
      echo $image;
      exit;
    }
    else
    {
      #header('Content-Type: image/jpg'); 
      #echo $image; 
      #exit; 
      #echo $image;
      var_dump($imgData);
      $error = "no mime";
    }
  }
  else
  {
    header("HTTP/1.0 404 Not Found");
    $error = "get image date error";
  }
}
else
{
  header("HTTP/1.0 404 Not Found");
  $error = "no img parameter";
}
echo $error;
?>
