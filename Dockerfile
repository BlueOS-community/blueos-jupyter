FROM python:3.11.9-bookworm

# Define arguments for target platform
# These arguments are defined automatically by buildx when using `--platform`
ARG TARGETARCH
ARG TARGETVARIANT

RUN echo "Building to: ${TARGETARCH} ${TARGETVARIANT}"

RUN apt update -y
RUN apt install -y nginx
RUN apt install -y cmake build-essential libffi-dev libzmq3-dev libopenblas-dev

RUN echo "Configuring pip to use piwheels"
RUN echo "[global]" >> /etc/pip.conf
RUN echo "extra-index-url=https://www.piwheels.org/simple" >> /etc/pip.conf

RUN pip install --no-cache-dir plotly --verbose
RUN pip install --no-cache-dir --verbose \
  bluerobotics-ping \
  bluerobotics-navigator

RUN pip install matplotlib
RUN pip install numpy
RUN pip install --no-cache-dir pymavlink --verbose
RUN pip install pyserial

# It takes forever to run this one!! Edit from this line below
RUN pip install --upgrade pip
RUN pip install cmake scikit-build --verbose
RUN apt install -y libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libgstreamer-plugins-bad1.0-dev gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-libav gstreamer1.0-tools gstreamer1.0-x gstreamer1.0-alsa gstreamer1.0-gl
RUN CMAKE_ARGS=-DPYTHON3_LIMITED_API=ON pip install opencv-python-headless --verbose

# This need to be after opencv
RUN pip install --no-cache-dir jupyterlab --verbose

RUN pip install mavsdk

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
      "/usr/blueos/extensions/jupyter/root:/root:rw",\
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
    "name": "Raul Victor Trombin",\
    "email": "raulvtrombin@gmail.com"\
  }\
]'
LABEL company='{\
  "about": "",\
  "name": "Blue Robotics",\
  "email": "support@bluerobotics.com"\
}'
LABEL readme="https://raw.githubusercontent.com/BlueOS-Community/blueos-jupyter/master/README.md"
LABEL type="other"
LABEL tags='[\
  "python",\
  "ide",\
  "development"\
]'

ENTRYPOINT ["/entrypoint.sh"]
