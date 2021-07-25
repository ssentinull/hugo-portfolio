# run hugo server locally
run:
	@hugo server

# build static pages, commit to github, & deploy to github.io 
deploy:
	@bash deploy.sh