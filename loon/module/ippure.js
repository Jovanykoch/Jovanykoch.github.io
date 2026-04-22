// Pure IP info panel for Loon/Surge/Quantumult X
$httpClient.get('https://ip.p3terx.com/ip', function (error, response, data) {
  if (error) {
    $done({title:"PureIP",content:"Network Error",icon:"wifi.exclamationmark"});
  } else {
    const ip = data.trim();
    $httpClient.get('https://ip.p3terx.com/cn', function (e, r, d) {
      let loc = (!e && d.trim()) ? d.trim() : "Unknown";
      $done({title:"PureIP",content:`${ip}\n${loc}` ,icon:"network"});
    });
  }
});