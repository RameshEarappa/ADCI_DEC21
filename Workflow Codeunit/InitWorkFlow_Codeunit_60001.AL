codeunit 60001 "Init Workflow"
{
    trigger OnRun()
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSendApproval_PR(var RecPurchaseReq: Record "Purchase Requisition Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnCancelApproval_PR(var RecPurchaseReq: Record "Purchase Requisition Header")
    begin
    end;
    //Event Creation End

    local procedure IsWFEnabled_PR(Var RecPurchaseReq: Record "Purchase Requisition Header"): Boolean
    var
        WFMngt: Codeunit "Workflow Management";
        WFCode: Codeunit "Customized Workflow";
    begin
        exit(WFMngt.CanExecuteWorkflow(RecPurchaseReq, WFCode.RunWorkflowOnSendApproval_PR))
    end;

    procedure CheckWorkflowEnabled(var RecPurchaseReq: Record "Purchase Requisition Header"): Boolean
    var
        NoWorkflowEnb: TextConst ENU = 'No workflow Enabled for this Record type', ENG = 'No workflow Enabled for this Record type';
    begin
        if not IsWFEnabled_PR(RecPurchaseReq) then
            Error(NoWorkflowEnb);
        exit(true);
    end;


    var
        WFMngt: Codeunit "Workflow Management";
        Text001: TextConst ENU = 'No Workflows Enabled';

}