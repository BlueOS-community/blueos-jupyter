FROM python:3.11.5-bookworm

RUN apt update -y
RUN apt install -y nginx
RUN apt install -y build-essential libffi-dev libzmq3-dev
RUN pip install --no-cache-dir jupyterlab --verbose
RUN pip install --no-cache-dir plotly --verbose
RUN pip install --no-cache-dir --verbose \
  bluerobotics-ping \
  bluerobotics-navigator
RUN pip install --no-cache-dir pymavlink --verbose

# Move our nginx configuration to the standard nginx path
COPY files/nginx.conf /etc/nginx/nginx.conf

# Add our static files to a common folder to be provided by nginx
RUN mkdir -p /site
COPY files/register_service /site/register_service

# Copy everything for your application
COPY files/entrypoint.sh /entrypoint.sh

RUN mkdir -p /home/workspace/.local
COPY examples /tmp/examples

# Add docker configuration
LABEL permissions='{\
  "NetworkMode": "host",\
  "HostConfig": {\
    "Privileged": true,\
    "Binds": [\
      "/usr/blueos/userdata/jupyter/root:/root:rw",\
      "/dev:/dev:rw"\
    ],\
    "Privileged": true,\
    "NetworkMode": "host"\
  }\
}'
LABEL authors='[\
  {\
    "name": "Patrick José Pereira",\
    "email": "patrickelectric@gmail.com"\
  },\
  {\
    "name": "Raul Trombin",\
    "email": "raulvtormbin@gmail.com"\
  }\
]'
LABEL company='{\
  "about": "",\
  "name": "Blue Robotics",\
  "email": "support@bluerobotics.com"\
}'
LABEL readme="https://raw.githubusercontent.com/patrickelectric/blueos-jupyter/master/README.md"
LABEL type="other"
LABEL tags='[\
  "python",\
  "ide",\
  "development"\
]'

ENTRYPOINT ["/entrypoint.sh"]