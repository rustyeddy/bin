srcdir   = src
srcfiles = lambda_function.py
pemfile  = ec2-key-pair.pem

zipfile  = otto.zip
pythonlib= env/lib/python2.7/site-packages
pythonlib64=env/lib64/python2.7/site-packages

all: clean $(zipfile)

$(srcdir)/$(pemfile) : $(EC2PAIR)
	cp $(EC2PAIR) $(srcdir)/$(pemfile)
	chmod 600 $(srcdir)/$(pemfile)

$(zipfile): $(srcdir)/$(pemfile) $(srcdir)/$(srcfiles)
	echo "Set EC2PAIR environment variable"
	echo "Copy application files into the build directory"
	rm -f $(zipfile)
	if [ ! -e $(srcdir)/$(pemfile) ]; then cp $(EC2PAIR) $(srcdir)/$(pemfile) ; fi ;
	chmod 644 $(srcdir)/$(pemfile)
	cd $(srcdir); zip -qr ../$(zipfile) $(srcfiles) $(pemfile)
	cd $(pythonlib); zip -qr ../../../../otto.zip .
	cd $(pythonlib64); zip -qr ../../../../otto.zip .
	echo "Now compress the build directory"
	ls -l otto.zip

deploy:
	aws lambda update-function-code --function-name dispatcher \
			--zip-file fileb://otto.zip --publish --region us-west-2 \
			&& touch .deployed

pipeline:
	aws codepipeline start-pipeline-execution --pipeline-name s3spa-codepipeline

invoke:
	aws lambda invoke --function-name dispatcher lamda-invoke.txt

#testit: .deployed
#	aws s3 rm s3://build.gumsole.com/otto.zip
#	aws s3 cp otto.zip s3://build.gumsole.com
#	touch .tested

cleanenv: clean
	rm -rf env*

cleanzip:
	rm -rf $(zipfile)

cleanall: $(cleanzip) $(cleanenv)

venv:
	virtualenv env
	env/bin/pip install --upgrade pip
	env/bin/pip install -r etc/requirements.txt
