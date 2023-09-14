RUN conda create -y -n jupyter jupyter

RUN mkdir -p /home/rstudio/logs/jupyter && \
   touch /home/rstudio/logs/jupyter/jupyter.log && \
   /home/rstudio/conda/envs/jupyter/bin/pip install environment_kernels && \
   conda install -n reticulate --update-all ipython
   # chmod u+x /home/rstudio/start-jupyter-service.sh && \
   # chown rstudio:rstudio /home/rstudio/start-jupyter-service.sh
COPY jupyter_notebook_config.py /home/rstudio/.jupyter/jupyter_notebook_config.py
COPY zeuscert.pem /home/rstudio/.jupyter/zeuscert.pem
COPY zeuskey.key /home/rstudio/.jupyter/zeuskey.key
RUN Rscript -e "Sys.setenv(PATH = paste('/home/rstudio/conda/envs/jupyter/bin:',Sys.getenv('PATH'), sep=':')); IRkernel::installspec()"


ENTRYPOINT [ "conda", "run", "-n", "jupyter", "jupyter", "notebook", "--config='/home/rstudio/.jupyter/jupyter_notebook_config.py'" ]


## Setup jupyter notebook installed in a conda env as a system service:
- [ ] Create a conda environment
```bash
conda create -n ENV_NAME
```
- [ ] Install jupyter and exec-wrappers into the conda env
```bash
conda install jupyter exec-wrappers -n ENV_NAME -c conda-forge
```
- [ ] Setup the wrapper around jupyter to handle environment activation
```bash
conda activate ENV_NAME
create-wrappers -t conda --bin-dir ~/miniconda3/envs/ENV_NAME/bin --dest-dir ~/.conda_wrappers --conda-env-dir ~/miniconda/envs/ENV_NAME
```
- [ ] Generate a jupyter config and setup a salted password (look this up elsewhere)
- [ ] Install 
- [ ] Add the start-jupyter-serivce.sh script to the user directory.
- [ ] Change the env name, user name, and location of jupyter-notebook executable
- [ ] Create jupyter.service file:
```bash
sudo vim /etc/systemd/system/jupyter.service
```
 * Alternatively, just download the file below and place it in the above directory.
- [ ] Create the service file and place it in the above directory
- [ ] Create the log file:
```bash
mkdir -p ~/logs/jupyter
touch ~/logs/jupyter/jupyter.log
```
- [ ] Place the start-jupyter-service.sh file in the users home directory and make it executable
```bash
chmod u+x ~/start-jupyter-service.sh
```
- [ ] Install and start the service
```bash
sudo systemctl enable jupyter.service
sudo systemctl daemon-reload
sudo systemctl restart jupyter.service
```
- [ ] Make sure the service is working
```bash
sudo service jupyter status
```
- [ ] (Optional) Install [jupyter-environment-kernels](https://github.com/Cadair/jupyter_environment_kernels)
```bash
pip install environment_kernels
```
Add `--NotebookApp.kernel_spec_manager_class='environment_kernels.EnvironmentKernelSpecManager'` to start-jupyter-service.sh