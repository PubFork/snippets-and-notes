# ZauberAutomato: automated rake testing in reproducible environment

# Build container to automatically provision environment and execute tests.
# sudo docker build -t zauberautomato .

# Start and enter container for troubleshooting if necessary.
# sudo docker run -it --rm zauberautomato (execute tests)
# sudo docker run -it -d zauberautomato (daemonize to enter container)
# sudo docker exec -it zauberautomato bash

# Remove running containers before rebuild.
# sudo docker ps -qa | xargs sudo docker kill

# Cleanup all instances when you are finished.
# sudo docker ps -qa | xargs sudo docker rm
# sudo docker images | grep zauberautomato | awk '{print $3}' | xargs sudo docker rmi

FROM fedora:28
RUN dnf install ruby -y
RUN gem install --no-document rake rspec rspec-its
COPY / .
ENTRYPOINT ["rake"]
