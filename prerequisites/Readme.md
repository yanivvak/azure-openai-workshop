
## Create the necessary Azure resources
- Insert your subscription ID in the file createAll.ps1 and save it. 
    ```
    $SubscriptionId = "<your subscription here>"
    ```

- This powershell script will create:
    - A resource group with name starting with 'aoai-workshop'
    - An AI Search service
    - An Azure OpenAI service with the following models:
        - GPT-4
        - GPT-4 Vision
        - Text Embedding Ada

- Go to the azure portal and login with a user that has permissions to create resource groups and resources in your subscription.
- Open the cloud shell in the azure portal
- Upload the files located in the `scripts` folder `createAll.ps1` and `deployAll.bicep`, ONE BY ONE by using the upload file button in the cloud shell
- Run `./createAll.ps1` in the cloud shell to create the resources

