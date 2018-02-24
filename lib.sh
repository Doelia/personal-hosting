create_machine()
{
	docker-machine create --driver amazonec2 --amazonec2-region $AWS_EC2_REGION --amazonec2-root-size $AWS_EC2_DISK_GO --amazonec2-instance-type $AWS_EC2_SIZE $AWS_EC2_ID
}

update_record()
{
	domain=$1
	ip=$2
	echo "Update DNS domain of $domain to $ip ..."

	list_to_delete=`curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$CLOUDFLARE_ZONE_ID/dns_records?name=$1" \
	     -H "X-Auth-Email: $CLOUDFLARE_EMAIL" \
	     -H "X-Auth-Key: $CLOUDFLARE_KEY" | \
	python -c "import sys, json; jsonr=json.load(sys.stdin); print '\n'.join(e for e in map(lambda x: x['id'], jsonr['result']))"
	`
	for id in $list_to_delete; do
		echo "Delete cloudflare record $id of domain $domain..."
		curl -s -X DELETE "https://api.cloudflare.com/client/v4/zones/$CLOUDFLARE_ZONE_ID/dns_records/$id" \
		     -H "X-Auth-Email: $CLOUDFLARE_EMAIL" \
		     -H "X-Auth-Key: $CLOUDFLARE_KEY" 
	done
	echo "\n\nCreate cloudflare record A $domain $ip ..."
		curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$CLOUDFLARE_ZONE_ID/dns_records" \
		     -H "X-Auth-Email: $CLOUDFLARE_EMAIL" \
		     -H "X-Auth-Key: $CLOUDFLARE_KEY" \
		     -H "content-type: application/json" \
		     --data "{\"type\":\"A\",\"name\":\"$domain\",\"content\":\"$ip\",\"ttl\":120,\"proxied\":false}"
		echo "\n"

}

build_docker_app()
{
	repo=$1
	rm -rf repos/$repo
	git clone https://github.com/doelia/$repo repos/$repo
	docker build repos/$repo -t $repo
}

