# Introducción

POC: Provisionar IaC con Terraform en AWS a través de CI/CD con Azure DevOps.

Se provisiona una instancia EC2 con linux Ubuntu 18.04 y servicio de nginx con su key pair y grupo de seguridad con permisos ingress por los puertos http y ssh desde cualquier lugar. El mensaje del servidor es: `I'm Nginx!`

También se provisiona un S3 bucket para almacenar el terraform.tfstate de los demás recursos. 

![AWS Resources](/img/dfd.jpg)

# Consideraciones Generales

* Seguir los pasos específicos descritos para su uso. 

* Estos pasos contemplan el uso de recursos en Azure DevOps como SCV y CI/CD.

* Tener presente que algunos recursos pueden incurrir costos fuera de la la capa gratuita de AWS.

* Eliminé los recursos tan pronto termine la POC. 

* Contar con credenciales de programmatic user de AWS 
 
* Contar con una cuenta en Azure DevOps

* En caso de usar otras CI/CD tools, queda del ejecutor adaptarlas. 

# Descripción 

### Este proyecto en una POC que provisiona los siguientes recursos en AWS desde IaC usuando Terraform a través de CI/CD en Azure DevOps.

## **Recursos en AWS**  

- 1 S3 standard bucket
- 1 Key pairs
- 1 Security groups
- 1 EC2 instance (Linux Ubuntu 18.04)
 
## **CI/CD en Azure DevOps**
  - 1 Repositorio     
  - 1 Pipeline      
  - 1 Service Connection (AWS for Terraform)
  - 1 Service Connection (AWS cli)

**Caso de uso:** Ejecución de de 1 pipeline para crear y destruir IaC.
El pipeline tiene 3 jobs: 
- A - Crea el S3 bucket para almacenar el terraform.tfstate de los siguientes jobs. 
- B - Crea la instncia, security group y key public pair fro the instance. 
- C - Elimina la IaC creada en el job B. hi

 # Estructura del proyecto 
- `/img` Contiene imágenes del README.md
- `/src` Contiene el código de la IaC 
    - `main.tf`  Archivo principal que contiene todos los recursos a crear
    - `variables.tf` Archivo con las variables de uso común
    - `install_nginx.sh` Script para instalar ngnix en linux
- `azure-pipeline-jobs.yml` CI/CD para construir/destruir la IaC 
- `.terraform.lock.hcl` Archivos de dependencias de paquetes y versiones del provedor cada vez que se ejecuta el init. [Conocer más aquí](https://www.terraform.io/docs/language/dependency-lock.html)

# Requisitios previos 
## Herramientas  
- Git 
- Amazon Web Services
- AWS cli
- Terraform 1.0.7v & Terraform for Azure DevOps
- Azure DevOps
- Visual Studio Code (*Opcional*)

## Técnicos 

- AWS programmatic user con permisos en EC2 y S3. 
    - Permisos en EC2 de lectura, escritura y eliminar. 
    - Permisos para S3 ver [aquí](https://www.terraform.io/docs/language/settings/backends/s3.html)
    - EC2 Key pair

# Instalaciones

*Siempre es mejor seguir los pasos desde los sitios oficiales para hacer las inatalaciones.*

## Para trabajo desde local en una Máquina Windows 

- [Instalar Chocholate](https://chocolatey.org/install)

- [Instalar Git](http://git-scm.com/download/win)

    - Actualizar la política Windows:
        1. Via Powershell admin ejecutar los siguientes comandos:

            - `set-executionpolicy remotesigned`
            -   `y`  para confirmar
            - `choco install -y git.install -params '"/GitAndUnixToolsOnPath"'`

        2. Reiniciar Powershell y ejecutar los siguientes comandos para cinfigurar Git:

            - `git config --global user.name "Your name"`
            - `git config --global user.email "your@email.com"`

    - [Instalar AWS cli](https://docs.aws.amazon.com/es_es/cli/latest/userguide/cli-chap-install.html)

        - Configurar un perfil de aws local: 
            - `aws configure --profile dev`
            > Introduzca sus credenciales.

    - [Instalar Terraform](https://www.terraform.io/downloads.html)

    -  Instalar VS Code (*Opcional*) [aquí](https://code.visualstudio.com/)

## Para trabajar directo desde Azure DevOps

- Usar/crear una cuenta de Azure DevOps [aquí](https://azure.microsoft.com/es-es/services/devops/)

- Pasos iniciales con Azure DevOps [aquí](https://azure.microsoft.com/es-es/overview/devops-tutorial/#understanding) 

# Construir y probar 
### Validar si S3 bucket existe: 
Antes de construir el pipeline en Azure DevOps es necesario validar la existencia del bucket. Se puede usar el siguiente comando desde la máquina local: 

ejemplo: 

    aws s3api head-bucket --bucket my-terra-bucket-99

[more info](https://docs.aws.amazon.com/cli/latest/reference/s3api/head-bucket.html)

### AWS EC2 key pair 
Crear o usar una ec2 key pair existente y reemplazar en el archivo main.tf en el recurso EC2, argumento `key_name`. 

## Usando Azure DevOps 
### Pasos Previos 
Antes de iniciar con la creación de los recursos en necesario instalar las herramientas:
- Terraform para Azure DevOps. Para instalarla seguir el siguiente [enlace](https://marketplace.visualstudio.com/items?itemName=ms-devlabs.custom-terraform-tasks).

- AWS Toolkit para Azure DevOps. Para instalarla seguir el siguiente [enlace](https://marketplace.visualstudio.com/items?itemName=AmazonWebServices.aws-vsts-tools).

### Crear Service Connetions (SC)
#### SC AWS para Terraform 
- Crear la conección con el servicio AWS for Terraform. Seguir los pasos descritos en el [enlace](https://help.veracode.com/r/Create_a_Service_Connection_in_Azure_DevOps); y para este caso, seleccionar `AWS para Terraform` como proveedor y agregar las credenciales correspondientes. 

- Una vez creada, seleccionar y copiar el ID que aparece en la url del navegador `https://dev.azure.com/organización/proyecto/_settings/adminservices?resourceId=59a2c16f-ed24-4b0e-b097-81f5586fbbcc`

     "resourceId=**59a2c16f-ed24-4b0e-b097-81f5586fbbcc**"

    Este ID se deberá reemplazar en los archivos de pipelines YAML en todas las tareas que contienen el input: `backendServiceAWS:59a2c16f-ed24-4b0e-b097-81f5586fbbcc`
    
    ejemplo: 
    ![ejemplo](/img/terraformawsconnection.jpg)

### Crear Repositorio
#### Opciones: 

1.  Se puede importar este repositorio desde github en Azure DevOps hacienco clic en "importar repositorio" en la sección de Repos ![](/data/reposicon.jpg), agregando la url del [origen](https://github.com/damitaintelectual/s3-ec2-aws-terraform). `(Requiere autenticación con las credenciales de github)`

2. Crear un nuevo repositorio en la sección de **Repos** y dar clic en `clonar usando VS Code` para llevarlo a la máquina local. Se creará una rama principal (`main`). 

    _(La autenticación se hace automática a través de un PAT entre los recursos de Microsoft)_

    2.1 Clonar este repositorio desde la máquina local con git clone y luego copiar los archivos en el repositorio creado en Azure DevOps:
            
        git clone https://github.com/damitaintelectual/s3-ec2-aws-terraform

        
### Crear Pipeline

Dirigirse a la sección de **Pipelines** uno para crear un pipeline y seleccionar:

- Crear nuevo pipeline a partir de Azure Repos Git YAML
- Seleccionar el repositorio origen
- Seleccionar la opción de archivo Azure pipeline YAML existente. 
- Elegir la rama `main` y seleccionar el archivo `azure-pipeline-jobs.yml`.
- Clic en Continuar y luego en Guardar.

*Es importante saber que cuando se crea un pipeline de esta forma, sus nombre será a partir del nombre del repositorio, por lo cual habrá que cambiarlo posteriormente a su creación.*

## Ejecutar Pipeline

### Pipeline para Construir y Eliminar recursos 
1. Ejecutar el pipeline `azure-pipeline-jobs.yml` para construir los recursos, yendo a la sección de pipelines y hacer clic en **RUN o Ejecutar**. 

**NOTA:**
- El job A crea el bucket S3 donde se guardará el terraform.tfstate.
- El job B construye los recursos EC2 y security group.
- El job C destruye los recursos creados en el job B.

Al terminar la ejecución del pipeline, se puede acceder a la consola de AWS para certificar que los recursos fueron eliminados correctamente. 

**Finalmente, eliminar el S3 bucket manualmente.**
 
# Contribuciones

- [AWS](https://docs.aws.amazon.com/es_es/)
- [HashiCorp](https://www.terraform.io/)
- [Azure DevOps](https://docs.microsoft.com/en-us/azure/devops/?view=azure-devops)
- [Visual Studio Code](https://github.com/Microsoft/vscode)