all:
	docker build -t devenv .

run:
	id
	docker run -it \
		-v ${HOME}:${HOME} \
		-v /etc/passwd:/etc/passwd \
		-v /etc/group:/etc/group \
		-u "$(shell id -u):$(shell id -g)" \
		--workdir="${HOME}" \
		-e "PS1=${PS1}"  -e "PS2=${PS1}>" \
		-e "HOME=${HOME}" \
		devenv
