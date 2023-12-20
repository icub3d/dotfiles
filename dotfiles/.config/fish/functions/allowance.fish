function allowance
	set MONGO_URI (bw-get-token mongo-bank-cloud-uri)
	bankctl -u $MONGO_URI -d bank add 1000 james.marshian@gmail.com allownace
	bankctl -u $MONGO_URI -d bank add 1000 william.marshian@gmail.com allowance
	bankctl -u $MONGO_URI -d bank add 1308 samuel.marshian@gmail.com allowance
end
