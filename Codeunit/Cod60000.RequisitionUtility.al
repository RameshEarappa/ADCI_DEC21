codeunit 60000 "Requisition Utility"
{

    trigger OnRun()
    var

    begin

    end;

    procedure CreateQuote(Var RecPurchRequisitionHdr: Record "Purchase Requisition Header"; VendorNumber: code[20]): Code[20]
    var
        RecPurchReqLine: Record "Purchase Requisition Line";
        RecPurchHeader: Record "Purchase Header";
        RecPurchLines: Record "Purchase Line";
        POLineNumber: Integer;
    begin
        /*Clear(RecPurchHeader);
        RecPurchHeader.SetRange("Document Type", RecPurchHeader."Document Type"::Quote);
        RecPurchHeader.SetRange("Purchase Requisition No.", RecPurchRequisitionHdr."No.");
        if RecPurchHeader.FindFirst() then
            if not Confirm('A quote is already created for this Purchase Requisition Card. Do you want to create another Purchase Quote?', false) then
                exit;*/
        Clear(RecPurchHeader);
        RecPurchHeader.SetRange("Document Type", RecPurchHeader."Document Type"::Quote);
        RecPurchHeader.SetRange("Purchase Requisition No.", RecPurchRequisitionHdr."No.");
        RecPurchHeader.SetRange("Buy-from Vendor No.", VendorNumber);
        if RecPurchHeader.FindFirst() then
            Error('A quote for this vendor related to this Purchase Requisition card is already created. Please choose another vendor');

        RecPurchHeader.Init();
        RecPurchHeader.Validate("Document Type", RecPurchHeader."Document Type"::Quote);
        RecPurchHeader.Insert(true);
        RecPurchHeader.validate("Buy-from Vendor No.", VendorNumber);
        RecPurchHeader.Validate("Purchase Requisition No.", RecPurchRequisitionHdr."No.");
        RecPurchHeader.Modify(true);
        Clear(POLineNumber);
        Clear(RecPurchReqLine);
        RecPurchReqLine.SetRange("Document No.", RecPurchRequisitionHdr."No.");
        if RecPurchReqLine.FindSet() then begin
            repeat
                POLineNumber += 10000;
                RecPurchLines.Init();
                RecPurchLines.Validate("Document Type", RecPurchLines."Document Type"::Quote);
                RecPurchLines.Validate("Document No.", RecPurchHeader."No.");
                RecPurchLines.Validate("Line No.", POLineNumber);
                case RecPurchReqLine.Type of
                    RecPurchReqLine.Type::Item:
                        RecPurchLines.Validate(Type, RecPurchLines.Type::Item);
                    RecPurchReqLine.Type::"Fixed Asset":
                        RecPurchLines.Validate(Type, RecPurchLines.Type::"Fixed Asset");
                    RecPurchReqLine.Type::"G/L Account":
                        RecPurchLines.Validate(Type, RecPurchLines.Type::"G/L Account");
                end;
                RecPurchLines.Validate("No.", RecPurchReqLine."No.");
                RecPurchLines.Validate(Description, RecPurchReqLine.Description);
                RecPurchLines.Validate(Quantity, RecPurchReqLine.Quantity);
                RecPurchLines.Validate("Item Category Code", RecPurchReqLine."Item Category Code");
                RecPurchLines.Validate("Location Code", RecPurchReqLine."Location Code");
                RecPurchLines.Validate("Unit of Measure", RecPurchReqLine."Unit of Measure Code");
                RecPurchLines.Validate("Direct Unit Cost", RecPurchReqLine."Direct Unit Cost");
                RecPurchLines.Insert(true);
            until RecPurchReqLine.Next() = 0;
        end;
        RecPurchRequisitionHdr.Validate(Status, RecPurchRequisitionHdr.Status::"Quote Created");
        RecPurchRequisitionHdr.Modify();
        exit(RecPurchHeader."No.");
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Quote to Order", 'OnBeforeDeletePurchQuote', '', false, false)]
    local procedure OnBeforeDeletePurchQuote(var QuotePurchHeader: Record "Purchase Header"; var OrderPurchHeader: Record "Purchase Header"; var IsHandled: Boolean);
    var
        RecPurchHeader: Record "Purchase Header";
        RecPurchLine: Record "Purchase Line";
        RecPurchaseQuoteHdr: Record "Purchase Quote Header";
        RecPurchQuoteLines: Record "Purchase Quote Lines";
        RecPurchaseRequisitionHdr: Record "Purchase Requisition Header";
    begin
        if QuotePurchHeader."Purchase Requisition No." <> '' then begin
            OrderPurchHeader."Purchase Requisition No." := QuotePurchHeader."Purchase Requisition No.";
            OrderPurchHeader.Modify();
            Clear(RecPurchaseRequisitionHdr);
            RecPurchaseRequisitionHdr.SetRange("No.", QuotePurchHeader."Purchase Requisition No.");
            if RecPurchaseRequisitionHdr.FindFirst() then begin
                RecPurchaseRequisitionHdr.Validate("Purchase Order No.", OrderPurchHeader."No.");
                RecPurchaseRequisitionHdr.Validate(Status, RecPurchaseRequisitionHdr.Status::"PO Created");
                RecPurchaseRequisitionHdr.Modify();
            end;
            Clear(RecPurchHeader);
            RecPurchHeader.SetRange("Document Type", RecPurchHeader."Document Type"::Quote);
            RecPurchHeader.SetRange("Purchase Requisition No.", QuotePurchHeader."Purchase Requisition No.");
            if RecPurchHeader.FindSet() then begin
                repeat
                    RecPurchaseQuoteHdr.Init();
                    RecPurchaseQuoteHdr.TransferFields(RecPurchHeader);
                    if RecPurchHeader."No." = QuotePurchHeader."No." then
                        RecPurchaseQuoteHdr."PO Creation Status" := RecPurchaseQuoteHdr."PO Creation Status"::"PO Created"
                    else
                        RecPurchaseQuoteHdr."PO Creation Status" := RecPurchaseQuoteHdr."PO Creation Status"::"Not Qualified";
                    RecPurchaseQuoteHdr.Insert();
                    Clear(RecPurchLine);
                    RecPurchLine.SetRange("Document Type", RecPurchLine."Document Type"::Quote);
                    RecPurchLine.SetRange("Document No.", RecPurchHeader."No.");
                    if RecPurchLine.FindSet() then begin
                        repeat
                            RecPurchQuoteLines.Init();
                            RecPurchQuoteLines.TransferFields(RecPurchLine);
                            RecPurchQuoteLines.Insert();
                        until RecPurchLine.Next() = 0;
                    end;
                    if RecPurchHeader."No." <> QuotePurchHeader."No." then
                        RecPurchHeader.Delete(true);
                until RecPurchHeader.Next() = 0;
            end

        end;
    end;

    procedure ReopenOrder(Var RecPurchReqP: Record "Purchase Requisition Header")
    begin
        RecPurchReqP.TestField(Status, RecPurchReqP.Status::Approved);
        RecPurchReqP.Validate(Status, RecPurchReqP.Status::Open);
        RecPurchReqP.Modify();
    end;

    procedure ValidateVendorPaymentApplication(var GenJnlLinep: Record "Gen. Journal Line")
    var
        GenJnlLine: Record "Gen. Journal Line";
        RecVendor: Record Vendor;
    begin
        GenJnlLine.Copy(GenJnlLinep);
        if GenJnlLine.FindSet() then begin
            repeat
                if GenJnlLine."Account Type" = GenJnlLine."Account Type"::Vendor then begin
                    Clear(RecVendor);
                    RecVendor.GET(GenJnlLine."Account No.");
                    if RecVendor."Vendor Type" = RecVendor."Vendor Type"::"Business Vendor" then begin
                        if (GenJnlLine."Applies-to Doc. No." = '') AND (GenJnlLine."Applies-to ID" = '') then
                            Error('%1 or %2 must have a value in %3. Line No. %4', GenJnlLine.FieldCaption("Applies-to Doc. No."), GenJnlLine.FieldCaption("Applies-to ID"), GenJnlLine.TableCaption, GenJnlLine."Line No.");
                    end;
                end;
            until GenJnlLine.Next() = 0;
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Document Attachment Factbox", 'OnBeforeDrillDown', '', false, false)]
    local procedure OnBeforeDrillDown(DocumentAttachment: Record "Document Attachment"; var RecRef: RecordRef);
    var
        RecPurchReq: Record "Purchase Requisition Header";
    begin
        if DocumentAttachment."Table ID" = DATABASE::"Purchase Requisition Header" then begin
            RecRef.Open(DATABASE::"Purchase Requisition Header");
            if RecPurchReq.Get(DocumentAttachment."No.") then
                RecRef.GetTable(RecPurchReq);
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Document Attachment Details", 'OnAfterOpenForRecRef', '', false, false)]
    local procedure OnAfterOpenForRecRef(var DocumentAttachment: Record "Document Attachment"; var RecRef: RecordRef; var FlowFieldsEditable: Boolean);
    var
        FieldRef: FieldRef;
        RecNo: Code[20];
    begin
        if RecRef.Number = Database::"Purchase Requisition Header" then begin
            FieldRef := RecRef.Field(1);
            RecNo := FieldRef.Value;
            DocumentAttachment.SetRange("No.", RecNo);
            DocumentAttachment.SetRange("Document Type", DocumentAttachment."Document Type"::"Purchase Requisition");
        end;
    end;

    procedure ValidateRequisitionBeforeSendingForApproval(RecHeader: Record "Purchase Requisition Header")
    var
        RecLines: Record "Purchase Requisition Line";
    begin
        Clear(RecLines);
        RecLines.SetRange("Document No.", RecHeader."No.");
        if RecLines.FindSet() then begin
            repeat
                RecLines.TestField("No.");
                RecLines.TestField(Quantity);
            until RecLines.Next() = 0;
        end
    end;
}
