/**
* @author William Chu (Slalom)
* @date 7/19/24
* @description Sandbox post refresh script
**/
public class SandboxPostRefreshScript implements SandboxPostCopy {
    public SandboxPostRefreshScript () {
    }

    public void runApexClass(SandboxContext context) {
        System.debug('Org ID: ' + context.organizationId());
        System.debug('Sandbox ID: ' + context.sandboxId());
        System.debug('Sandbox Name: ' + context.sandboxName());
        Database.executeBatch(new SandboxPostRefreshInvalidateEmailsBatch());
    }
}