#!/bin/bash



#stat() {


printMetric() {
#    echo "# HELP $1 $2"
#    echo "# TYPE $1 $3"
    echo "$1 $4"
}

api() { curl -s 127.0.0.1:14002/api/$1; }

DASHDATA=`api "dashboard"`


printMetric "node_id{node_id=\"`echo $DASHDATA | jq -r .data.nodeID`\", version=\"`echo $DASHDATA | jq -r '(.data.version)'`\"}" "node_id" "gauge" 1 
printMetric "diskspace_avail" "bandwidth_avail" "gauge" `echo $DASHDATA | jq -r '.data.diskSpace.available'`
printMetric "diskspace_used" "bandwidth_avail" "gauge" `echo $DASHDATA | jq -r '.data.diskSpace.used'`
printMetric "bandwidth_avail" "bandwidth_avail" "gauge" `echo $DASHDATA | jq -r '.data.bandwidth.available'`
printMetric "bandwidth_used" "bandwidth_used" "gauge" `echo $DASHDATA | jq -r '.data.bandwidth.used'`
printMetric "last_ping{}" "last_pinged" "gauge" `echo $DASHDATA | jq '.data.lastPinged | sub(".[0-9]+Z$"; "Z") | fromdate'`

#echo $DASHDATA | jq -r '.data.satellites[].id'

for sat in `echo $DASHDATA | jq -r '.data.satellites[].id'`
do

SATDATA=`api "satellite/$sat"`
printMetric "satellite_totalcount{satellite_id=\"${sat}\"}" "satellite_totalcount" "gauge" `echo $SATDATA| jq -r '.data.audit.totalCount'`;
printMetric "satellite_successcount{satellite_id=\"${sat}\"}" "satellite_successcount" "gauge" `echo $SATDATA| jq -r '.data.audit.successCount'`;
printMetric "satellite_auditscore{satellite_id=\"${sat}\"}" "satellite_auditscore" "gauge" `echo $SATDATA| jq -r '.data.audit.score'`;
printMetric "satellite_uptime_totalcount{satellite_id=\"${sat}\"}" "satellite_uptime_totalcount" "gauge" `echo $SATDATA| jq -r '.data.uptime.totalCount'`;
printMetric "satellite_uptime_successcount{satellite_id=\"${sat}\"}" "satellite_uptime_successcount" "gauge" `echo $SATDATA| jq -r '.data.uptime.successCount'`;
printMetric "satellite_uptime_score{satellite_id=\"${sat}\"}" "satellite_uptime_score" "gauge" `echo $SATDATA| jq -r '.data.uptime.score'`;
printMetric "satellite_egress{satellite_id=\"${sat}\"}" "satellite_egress" "gauge" `echo $SATDATA| jq -r 'select (.data.bandwidthDaily != null) | .data.bandwidthDaily | map (.egress.usage) | add'`
printMetric "satellite_egress_repair{satellite_id=\"${sat}\"}" "satellite_egress_repair" "gauge" `echo $SATDATA| jq -r 'select (.data.bandwidthDaily != null) | .data.bandwidthDaily | map (.egress.repair) | add'`
printMetric "satellite_egress_audit{satellite_id=\"${sat}\"}" "satellite_egress_audit" "gauge" `echo $SATDATA| jq -r 'select (.data.bandwidthDaily != null) | .data.bandwidthDaily | map (.egress.audit) | add'`
printMetric "satellite_ingress{satellite_id=\"${sat}\"}" "satellite_ingress" "gauge" `echo $SATDATA| jq -r 'select (.data.bandwidthDaily != null) | .data.bandwidthDaily | map (.ingress.usage) | add'`

done

