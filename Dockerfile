FROM python:2
MAINTAINER Tyler Christiansen <code@tylerc.me>

ARG user=lab
ARG pass=demo
EXPOSE 22

RUN mkdir /var/run/sshd
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

# Aker Shit.
# The pip installation step will change once
# https://github.com/aker-gateway/Aker/pull/26
# is merged
RUN pip install git+https://github.com/supertylerc/Aker.git@feat/setup-py
COPY aker.ini /etc/aker.ini
RUN echo "$(which aker)" >> /etc/shells

# Add user and passworda
RUN useradd -ms $(which aker) $user
RUN echo "$user:$pass" | chpasswd

# Install SSH Shit
RUN apt-get update && apt-get install -y openssh-server

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

CMD ["/usr/sbin/sshd", "-D"]
