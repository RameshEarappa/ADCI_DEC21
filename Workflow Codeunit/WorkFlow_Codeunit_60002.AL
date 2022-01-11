codeunit 60002 "Customized Workflow"
{
    //Workflow demo created by Krishna Kumar 22 Oct 2020

    trigger OnRun()
    begin

    end;

    var
        WFMngt: Codeunit "Workflow Management";
        AppMgmt: Codeunit "Approvals Mgmt.";
        WorkflowEventHandling: Codeunit "Workflow Event Handling";
        WorkflowResponseHandling: Codeunit "Workflow Response Handling";



    //**************************Send For Approval Event Start***************************
    procedure RunWorkflowOnSendApproval_PR(): Code[128]
    begin
        exit('RunWorkflowOnSendApproval_PR');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Init Workflow", 'OnSendApproval_PR', '', true, true)]
    procedure RunWorkflowOnSendApprovalForTO(var RecPurchaseReq: Record "Purchase Requisition Header")
    begin
        WFMngt.HandleEvent(RunWorkflowOnSendApproval_PR, RecPurchaseReq);
    end;


    //************* To set status pending approval *************
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnSetStatusToPendingApproval', '', false, false)]
    procedure ChangeAssetStatus(RecRef: RecordRef; var Variant: Variant; var IsHandled: Boolean)
    VAR
        RecPurchReq: Record "Purchase Requisition Header";
    begin
        RecRef.GetTable(Variant);
        case RecRef.Number of
            DATABASE::"Purchase Requisition Header":
                begin
                    RecRef.SetTable(RecPurchReq);
                    RecPurchReq.Validate("Status", RecPurchReq."Status"::"Pending Approval");
                    RecPurchReq.Modify(true);
                    Variant := RecPurchReq;
                    IsHandled := true;
                end;
        end;
    end;
    //****************************************** Send For Approval End ***********************


    //************ After approval *** Set status to Approved**************
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnReleaseDocument', '', false, false)]
    procedure OnReleaseDocument(RecRef: RecordRef; VAR Handled: Boolean)
    var
        RecPurchReq: Record "Purchase Requisition Header";
        Variant: Variant;
    begin
        CASE RecRef.NUMBER OF
            DATABASE::"Purchase Requisition Header":
                BEGIN
                    RecRef.SetTable(RecPurchReq);
                    RecPurchReq."Status" := RecPurchReq."Status"::Approved;
                    RecPurchReq.Modify(true);
                    Variant := RecPurchReq;
                    RecRef.GetTable(Variant);
                    Handled := true;
                END;
        end;
    end;


    //*******************On Populate Approval Entry *********************
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnPopulateApprovalEntryArgument', '', true, true)]
    procedure OnPopulateApprovalEntryArgument(var RecRef: RecordRef; var ApprovalEntryArgument: Record "Approval Entry"; WorkflowStepInstance: Record "Workflow Step Instance")
    var
        RecPurchReq: Record "Purchase Requisition Header";
    begin
        case RecRef.Number of
            database::"Purchase Requisition Header":
                begin
                    RecRef.SetTable(RecPurchReq);
                    ApprovalEntryArgument."Table ID" := Database::"Purchase Requisition Header";
                    ApprovalEntryArgument."Document No." := RecPurchReq."No.";
                    RecRef.GetTable(RecPurchReq);
                end;
        end;
    end;





    //******************To cancel approval in case of 2nd level***************** 
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Management", 'OnBeforeHandleEventWithxRec', '', false, false)]
    procedure OnBeforeHandleEventWithxRec(FunctionName: Code[128]; Variant: Variant; xVariant: Variant; VAR IsHandled: Boolean)
    Var
        RecPurchReq: Record "Purchase Requisition Header";
        RecRef: RecordRef;
        RecApprovalEntry: Record "Approval Entry";
        ActionableWorkflowStepInstance: Record "Workflow Step Instance";
        WorkFlowMgmt: Codeunit "Workflow Management";
    begin
        RecRef.GetTable(Variant);
        if (RecRef.Number = Database::"Purchase Requisition Header") AND (FunctionName = RunWorkflowOnCancelApproval_PR()) Then begin
            IF NOT WorkFlowMgmt.FindEventWorkflowStepInstance(ActionableWorkflowStepInstance, FunctionName, Variant, xVariant) THEN BEGIN
                RecPurchReq := Variant;
                Clear(RecApprovalEntry);
                RecApprovalEntry.SetRange("Table ID", Database::"Purchase Requisition Header");
                RecApprovalEntry.SetRange("Document No.", RecPurchReq."No.");
                RecApprovalEntry.SetRange("Record ID to Approve", RecPurchReq.RecordId);
                RecApprovalEntry.SetFilter(Status, '%1|%2', RecApprovalEntry.Status::Created, RecApprovalEntry.Status::Open);
                if RecApprovalEntry.FindSet() then
                    RecApprovalEntry.ModifyAll(Status, RecApprovalEntry.Status::Canceled);
                RecPurchReq.Validate("Status", RecPurchReq."Status"::Open);
                RecPurchReq.Modify();
                Variant := RecPurchReq;
                Message('Purchase Requisition approval request has been cancelled.');
            END;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Event Handling", 'OnAddWorkflowEventsToLibrary', '', false, false)]
    procedure AddEventsToLibrary()
    begin
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnSendApproval_PR(), Database::"Purchase Requisition Header", 'Purchase Requisition approval required', 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnCancelApproval_PR(), Database::"Purchase Requisition Header", 'Purchase Requisition cancel request', 0, false);
    end;

    //****************Reject***************
    procedure RunWorkflowOnReject_PR(): Code[128]
    begin
        exit('RunWorkflowOnReject_PR');
    end;
    //****************Reject End***************



    //***********************Cancel For Approval Event  Start******************
    procedure RunWorkflowOnCancelApproval_PR(): Code[128]
    begin
        exit('RunWorkflowOnCancelApproval_PR');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Init Workflow", 'OnCancelApproval_PR', '', true, true)]
    procedure RunWorkflow_OnCancelApproval_PR(var RecPurchaseReq: Record "Purchase Requisition Header")
    begin
        WFMngt.HandleEvent(RunWorkflowOnCancelApproval_PR, RecPurchaseReq);
    end;
    //***********************End***********************************


    //****************In case of Reject and cancel Approval request***********
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnOpenDocument', '', false, false)]
    procedure OnOpenDocument(RecRef: RecordRef; VAR Handled: Boolean)
    VAR
        RecPurchReq: Record "Purchase Requisition Header";
        Variant: Variant;
    begin
        CASE RecRef.NUMBER OF
            DATABASE::"Purchase Requisition Header":
                BEGIN
                    RecRef.SetTable(RecPurchReq);
                    RecPurchReq."Status" := RecPurchReq."Status"::Open;
                    RecPurchReq.Modify(true);
                    Variant := RecPurchReq;
                    RecRef.GetTable(Variant);
                    Handled := true;
                END;
        end;

    end;

    //Code to Open Record from Request to Appprove page//Krishna
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Page Management", 'OnConditionalCardPageIDNotFound', '', false, false)]
    local procedure OnConditionalCardPageIDNotFound(RecordRef: RecordRef; VAR CardPageID: Integer)
    begin
        CASE RecordRef.NUMBER OF
            DATABASE::"Purchase Requisition Header":
                CardPageID := Page::"Purchase Requisition";
        end;
    end;
}