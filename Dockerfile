FROM continuumio/miniconda3:4.7.12

RUN mkdir /projects
RUN sed -i -e 's/\/root/\/projects/g' /etc/passwd

RUN conda install -c conda-forge conda=4.7.12 jupyterlab=2.1.4 nodejs=10.13.0 gitpython=3.1.3
RUN conda install -c conda-forge papermill

USER root

# Grant access to jupyterlab config files for base url rewriting
RUN chmod a+rwx -R /opt/conda/lib/python*/site-packages/

# Adjust permissions on /etc/passwd so writable by group root.
RUN chmod g+w /etc/passwd
RUN chmod g+w /etc/environment

###############################
# Custom Jupyter Extensions
###############################
COPY maap-jupyter-ide /maap-jupyter-ide

WORKDIR /maap-jupyter-ide
RUN npm install typescript -g

# control che side panel extension
RUN cd hide_side_panel && npm install \
    && npm run build \
    && jupyter labextension install --no-build

RUN jupyter lab build && \
    jupyter lab clean && \
    jlpm cache clean && \
    npm cache clean --force && \
    rm -rf $HOME/.node-gyp && \
    rm -rf $HOME/.local

RUN mkdir /.jupyter
RUN touch /root/.bashrc && echo "cd /projects >& /dev/null" >> /root/.bashrc
RUN echo "PATH=/opt/conda/bin:${PATH}" >> /etc/environment

RUN chmod a+rwx -R /maap-jupyter-ide/ && chmod a+rwx -R /.jupyter

ENV SHELL="bash"

WORKDIR /projects
EXPOSE 3100

ENTRYPOINT ["/bin/bash", "/maap-jupyter-ide/entrypoint.sh"]
