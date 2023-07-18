:global zoneId;
:global recordId;
:global tokenKey;
:global recordName;
:global proxied;

:global wanIp;

:local newIp [/ip cloud get public-address];

:if ($wanIp != $newIp) do={
   /tool fetch mode=https http-method=put \
     url="https://api.cloudflare.com/client/v4/zones/$zoneId/dns_records/$recordId" \
     http-header-field="Authorization: Bearer $tokenKey" \
     http-data="{\"type\":\"A\",\"name\":\"$recordName\",\"content\":\"$newIp\",\"proxied\":$proxied}" output=none;
   :log info "New IP detected $newIp";
   :set wanIp $newIp;
}
