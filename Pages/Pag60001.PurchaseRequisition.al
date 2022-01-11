page 60001 "Purchase Requisition"
{
    Caption = 'Purchase Requisition';
    PageType = Document;
    SourceTable = "Purchase Requisition Header";
    DataCaptionFields = "No.", Description;
    PromotedActionCategories = 'New,Process,Report,Request Approval,Print/Send,Navigate,Related';

    layout
    {
        area(content)
        {
            group(General)
            {
                field("No."; Rec."No.")
                {
                    ToolTip = 'Specifies the value of the No. field.';
                    ApplicationArea = All;
                    Editable = PageEditable;
                    trigger OnAssistEdit()
                    begin
                        if Rec.AssistEdit(xRec) then
                            CurrPage.Update();
                    end;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field.';
                    ApplicationArea = All;
                    Editable = PageEditable;
                }
                field(Status; Rec.Status)
                {
                    ToolTip = 'Specifies the value of the Status field.';
                    ApplicationArea = All;
                    StyleExpr = StyleText;
                    Editable = false;
                }
                field("Purchase Order No."; Rec."Purchase Order No.")
                {
                    ToolTip = 'Specifies the value of the Purchase Order No. field.';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Open Purchase Quotes"; Rec."Open Purchase Quotes")
                {
                    ToolTip = 'Specifies the value of the Vendor Purchase Quotes field.';
                    ApplicationArea = All;
                    DrillDown = true;
                    DrillDownPageId = "Purchase Quotes";
                }
                field("Purch. Quotes converted to PO"; Rec."Purch. Quotes converted to PO")
                {
                    ApplicationArea = All;
                    DrillDown = true;
                    DrillDownPageId = "Purch. Quotes converted to PO";
                }
                field("Purchase Quotes Not Qualified"; Rec."Purchase Quotes Not Qualified")
                {
                    ApplicationArea = All;
                    DrillDown = true;
                    DrillDownPageId = "Purch. Quotes Not Qualified";
                }
                field("Required By Date"; Rec."Required By Date")
                {
                    ToolTip = 'Specifies the value of the Required By Date field.';
                    ApplicationArea = All;
                    Editable = PageEditable;
                }
                field("Requisition Type"; Rec."Requisition Type")
                {
                    ToolTip = 'Specifies the value of the Requisition Type field.';
                    ApplicationArea = All;
                    Editable = PageEditable;
                }
                field("Requested By"; Rec."Requested By")
                {
                    ToolTip = 'Specifies the value of the Requested By field.';
                    ApplicationArea = All;
                    Editable = PageEditable;
                }
                field("Requester Ext."; Rec."Requester Ext.")
                {
                    ToolTip = 'Specifies the value of the Requester Ext. field.';
                    ApplicationArea = All;
                    Editable = PageEditable;
                }
                field("Created By"; Rec."Created By")
                {
                    ToolTip = 'Specifies the value of the Created By field.';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Items Type ADCI"; Rec."Items Type ADCI")
                {
                    ToolTip = 'Specifies the value of the Items Type field.';
                    ApplicationArea = All;
                }
                field("Existing Service ADCI"; Rec."Existing Service ADCI")
                {
                    ToolTip = 'Specifies the value of the Existing Service field.';
                    ApplicationArea = All;
                    trigger OnValidate()
                    begin
                        if Rec."Existing Service ADCI" then
                            SetEditable := true
                        else
                            SetEditable := false;
                    end;
                }
                field(Name_ADCI; Rec.Name_ADCI)
                {
                    ToolTip = 'Specifies the value of the Name field.';
                    ApplicationArea = All;
                    Editable = SetEditable;
                }
                field("Department BU ADCI"; Rec."Department BU ADCI")
                {
                    ToolTip = 'Specifies the value of the Department BU field.';
                    ApplicationArea = All;
                }
                field(Remarks; Rec.Remarks)
                {
                    ToolTip = 'Specifies the value of the Remarks field.';
                    ApplicationArea = All;
                    MultiLine = true;
                    Editable = PageEditable;
                }
            }
            part(Lines; "Purchase Requisition Lines")
            {
                ApplicationArea = All;
                Enabled = (Rec."No." <> '') AND (PageEditable);
                SubPageLink = "Document No." = FIELD("No.");
                UpdatePropagation = Both;
            }
        }
        area(factboxes)
        {
            part("Attached Documents"; "Document Attachment Factbox")
            {
                ApplicationArea = All;
                Caption = 'Attachments';
                SubPageLink = "Table ID" = CONST(60000),
                              "No." = FIELD("No."),
                              "Document Type" = const("Purchase Requisition");
            }
        }
    }
    actions
    {
        area(Processing)
        {
            group("Im&port")
            {
                Caption = 'Import';
                action("Import")
                {
                    ApplicationArea = All;
                    Image = Import;
                    Promoted = true;
                    PromotedCategory = Category6;
                    PromotedOnly = true;
                    trigger OnAction()
                    var
                        ImportLines: XmlPort "Import Purchase Requisition";
                    begin
                        Rec.TestField("No.");
                        Rec.TestField(Status, Rec.Status::Open);
                        Clear(ImportLines);
                        ImportLines.SetDOcumentNumber(Rec."No.");
                        ImportLines.Run();
                    end;
                }
            }

            action("Reopen")
            {
                ApplicationArea = All;
                Image = ReOpen;
                Promoted = true;
                PromotedCategory = Category6;
                PromotedOnly = true;
                Enabled = (Rec.Status = Rec.Status::Approved);
                trigger OnAction()
                var
                    Utility: Codeunit "Requisition Utility";
                begin
                    Utility.ReopenOrder(Rec);
                end;
            }

            action("Create Purchase Quote")
            {
                ApplicationArea = All;
                Image = Import;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                trigger OnAction()
                var
                    RecVendor: Record Vendor;
                    PageVendorLookup: Page "Vendor Lookup";
                    Utility: Codeunit "Requisition Utility";
                    PQNumber: code[20];
                begin
                    if NOT (Rec.Status IN [Rec.Status::Approved, Rec.Status::"Quote Created"]) then
                        Rec.TestField(Status, Rec.Status::Approved);
                    if Rec.Status = Rec.Status::"Quote Created" then begin
                        if not Confirm('A quote is already created for this Purchase Requisition Card. Do you want to create another Purchase Quote?', false) then
                            exit;
                    end;
                    Clear(RecVendor);
                    RecVendor.SetRange(Blocked, RecVendor.Blocked::" ");
                    Clear(PageVendorLookup);
                    PageVendorLookup.SetTableView(RecVendor);
                    PageVendorLookup.SetRecord(RecVendor);
                    PageVendorLookup.LookupMode := true;
                    if PageVendorLookup.RunModal() IN [Action::LookupOK, Action::OK] then begin
                        Clear(RecVendor);
                        Clear(PQNumber);
                        PageVendorLookup.GetRecord(RecVendor);
                        PQNumber := Utility.CreateQuote(Rec, RecVendor."No.");
                        if PQNumber <> '' then
                            Message('A Purchase Quote %1 has been created.', PQNumber);
                    end;
                end;
            }
            action("Purchase Quote List")
            {
                ApplicationArea = All;
                Image = ShowList;
                Promoted = true;
                PromotedCategory = Category6;
                PromotedOnly = true;
                trigger OnAction()
                var
                    RecPurchHdr: Record "Purchase Header";
                begin
                    Clear(RecPurchHdr);
                    RecPurchHdr.SetRange("Document Type", RecPurchHdr."Document Type"::Quote);
                    RecPurchHdr.SetRange("Purchase Requisition No.", Rec."No.");
                    if RecPurchHdr.FindSet() then;
                    Page.Run(Page::"Purchase Quotes", RecPurchHdr);
                end;
            }
            action("Purchase Order Card")
            {
                ApplicationArea = All;
                Image = Card;
                Promoted = true;
                PromotedCategory = Category6;
                PromotedOnly = true;
                trigger OnAction()
                var
                    RecPurchHdr: Record "Purchase Header";
                begin
                    Rec.TestField(Status, Rec.Status::"PO Created");
                    Clear(RecPurchHdr);
                    RecPurchHdr.SetRange("Document Type", RecPurchHdr."Document Type"::Order);
                    RecPurchHdr.SetRange("Purchase Requisition No.", Rec."No.");
                    if RecPurchHdr.FindSet() then;
                    Page.Run(Page::"Purchase Order", RecPurchHdr);
                end;
            }
            group(Print)
            {
                action(Procurement)
                {
                    Caption = 'Purchase Requisition Report';
                    Image = PrintReport;
                    ApplicationArea = All;
                    trigger OnAction()
                    var
                        PRHL: Record "Purchase Requisition Header";
                    begin
                        Clear(PRHL);
                        PRHL.SetRange("No.", Rec."No.");
                        if PRHL.FindFirst() then
                            Report.RunModal(60000, true, false, PRHL);
                    end;
                }
                action(QuoteReport)
                {
                    Caption = 'Quote Comparison Report';
                    Image = PrintReport;
                    ApplicationArea = All;
                    trigger OnAction()
                    var
                        PRLL: Record "Purchase Requisition Line";
                    begin
                        Clear(PRLL);
                        PRLL.SetRange("Document No.", Rec."No.");
                        if PRLL.FindFirst() then
                            Report.RunModal(60001, true, false, PRLL);
                    end;
                }
            }
        }

        area(Navigation)
        {
            group("Request Approval")
            {
                Caption = 'Request Approval';
                action("Send Approval Request")
                {
                    Caption = 'Send Approval Request';
                    Enabled = IsSendRequest;
                    Image = SendApprovalRequest;
                    ApplicationArea = All;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedOnly = true;
                    PromotedIsBig = true;

                    trigger OnAction()
                    var
                        WfInitCode: Codeunit "Init Workflow";
                        AdvanceWorkflowCUL: Codeunit "Customized Workflow";
                        Utility: Codeunit "Requisition Utility";
                    begin
                        Rec.TestField(Status, Rec.Status::Open);
                        Utility.ValidateRequisitionBeforeSendingForApproval(Rec);
                        if WfInitCode.CheckWorkflowEnabled(Rec) then begin
                            WfInitCode.OnSendApproval_PR(Rec);
                        end;
                        //SetControl();
                    end;
                }

                action("Cancel Approval Request")
                {
                    Caption = 'Cancel Approval Request';
                    Enabled = IsCancel;
                    ApplicationArea = All;
                    Image = CancelApprovalRequest;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;

                    trigger OnAction()
                    var
                        InitWf: Codeunit "Init Workflow";
                    begin
                        InitWf.OnCancelApproval_PR(Rec);
                        //SetControl();
                    end;
                }
            }

            group(Approval)
            {
                Caption = 'Approval';
                action(Approve)
                {
                    ApplicationArea = Suite;
                    Caption = 'Approve';
                    Image = Approve;
                    Promoted = true;
                    PromotedCategory = Category6;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    ToolTip = 'Approve the requested changes.';
                    Visible = OpenApprovalEntriesExistForCurrUser;

                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    begin
                        ApprovalsMgmt.ApproveRecordApprovalRequest(Rec.RecordId);
                    end;
                }
                action(Reject)
                {
                    ApplicationArea = Suite;
                    Caption = 'Reject';
                    Image = Reject;
                    Promoted = true;
                    PromotedCategory = Category6;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    ToolTip = 'Reject to approve the incoming document.';
                    Visible = OpenApprovalEntriesExistForCurrUser;

                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    begin
                        ApprovalsMgmt.RejectRecordApprovalRequest(Rec.RecordId);
                    end;
                }
                action(Delegate)
                {
                    ApplicationArea = Suite;
                    Caption = 'Delegate';
                    Image = Delegate;
                    Promoted = true;
                    PromotedCategory = Category6;
                    PromotedOnly = true;
                    ToolTip = 'Delegate the approval to a substitute approver.';
                    Visible = false;// OpenApprovalEntriesExistForCurrUser;

                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    begin
                        ApprovalsMgmt.DelegateRecordApprovalRequest(Rec.RecordId);
                    end;
                }
                action(Comment)
                {
                    ApplicationArea = Suite;
                    Caption = 'Comments';
                    Image = ViewComments;
                    Promoted = true;
                    PromotedCategory = Category6;
                    PromotedOnly = true;
                    ToolTip = 'View or add comments for the record.';
                    Visible = OpenApprovalEntriesExistForCurrUser;

                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    begin
                        ApprovalsMgmt.GetApprovalComment(Rec);
                    end;
                }
                action(Approvals)
                {
                    AccessByPermission = TableData "Approval Entry" = R;
                    ApplicationArea = Suite;
                    Caption = 'Approvals';
                    Image = Approvals;
                    Promoted = true;
                    PromotedCategory = Category7;
                    ToolTip = 'View a list of the records that are waiting to be approved. For example, you can see who requested the record to be approved, when it was sent, and when it is due to be approved.';

                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    begin
                        ApprovalsMgmt.RunWorkflowEntriesPage(Rec.RecordId(), DATABASE::"Purchase Requisition Header", Enum::"Approval Document Type"::" ", Rec."No.");
                    end;
                }
            }
        }
    }
    trigger OnAfterGetRecord()
    begin
        SetControl();
    end;

    trigger OnOpenPage()
    begin
        SetControl();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        SetControl();
    end;

    local procedure SetControl()
    var
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
    begin
        OpenApprovalEntriesExistForCurrUser := ApprovalsMgmt.HasOpenApprovalEntriesForCurrentUser(Rec.RecordId);
        if Rec."Status" = Rec."Status"::Open then begin
            IsSendRequest := true;
            IsCancel := false;
            PageEditable := true;
            StyleText := '';
        end else
            if Rec."Status" = Rec."Status"::"Pending Approval" then begin
                IsSendRequest := false;
                IsCancel := true;
                PageEditable := false;
                StyleText := 'Ambiguous';
            end else begin
                IsSendRequest := false;
                IsCancel := false;
                PageEditable := false;
                StyleText := 'Favorable';
            end;
        CurrPage.Update(false);
    end;

    var
        IsSendRequest: Boolean;
        PageEditable: Boolean;
        IsCancel: Boolean;
        OpenApprovalEntriesExistForCurrUser: Boolean;
        StyleText: Text;
        SetEditable: Boolean;
}
