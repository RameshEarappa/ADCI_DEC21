table 60000 "Purchase Requisition Header"
{
    Caption = 'Purchase Requisition Header';
    DataClassification = ToBeClassified;
    DataCaptionFields = "No.", Description;
    LookupPageId = "Purchase Requisitions";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = ToBeClassified;
            trigger OnValidate()
            begin
                if "No." <> xRec."No." then begin
                    GetPurchSetup();
                    NoSeriesMgt.TestManual(RecPnP."Purchase Requisition Nos.");
                end;
            end;
        }
        field(2; Description; Text[250])
        {
            Caption = 'Description';
            DataClassification = ToBeClassified;
        }
        field(3; Status; Option)
        {
            Caption = 'Status';
            DataClassification = ToBeClassified;
            OptionMembers = Open,"Pending Approval",Approved,"Quote Created","PO Created";
            Editable = false;
        }
        field(4; "Purchase Order No."; Code[20])
        {
            Caption = 'Purchase Order No.';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(5; "Open Purchase Quotes"; Integer)
        {
            Caption = 'Open Purchase Quotes';
            FieldClass = FlowField;
            CalcFormula = count("Purchase Header" where("Document Type" = const(Quote), "Purchase Requisition No." = field("No.")));
        }
        field(6; "Required By Date"; Date)
        {
            Caption = 'Required By Date';
            DataClassification = ToBeClassified;
        }
        field(7; "Requisition Type"; Option)
        {
            Caption = 'Requisition Type';
            DataClassification = ToBeClassified;
            OptionMembers = " ",Stock,"Non-Stock",Expense,Asset;
        }
        field(8; "Requested By"; Code[50])
        {
            Caption = 'Requested By';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = User."User Name";
            ValidateTableRelation = false;
            trigger OnValidate()
            var
                UserSelection: Codeunit "User Selection";
            begin
                UserSelection.ValidateUserName("Requested By");
            end;
        }
        field(9; "Requester Ext."; Text[250])
        {
            Caption = 'Requester Ext.';
            DataClassification = ToBeClassified;
        }
        field(10; "Created By"; Code[50])
        {
            Caption = 'Created By';
            Editable = false;
            DataClassification = ToBeClassified;
            TableRelation = User."User Name";
            ValidateTableRelation = false;
            trigger OnValidate()
            var
                UserSelection: Codeunit "User Selection";
            begin
                UserSelection.ValidateUserName("Requested By");
            end;
        }
        field(11; Remarks; Text[250])
        {
            Caption = 'Remarks';
            DataClassification = ToBeClassified;
        }
        field(12; "Purch. Quotes converted to PO"; Integer)
        {
            Caption = 'Purchase Quotes converted to PO';
            FieldClass = FlowField;
            CalcFormula = count("Purchase Quote Header" where("Document Type" = const(Quote), "Purchase Requisition No." = field("No."), "PO Creation Status" = const("PO Created")));
        }
        field(13; "Purchase Quotes Not Qualified"; Integer)
        {
            Caption = 'Purchase Quotes Not Qualified';
            FieldClass = FlowField;
            CalcFormula = count("Purchase Quote Header" where("Document Type" = const(Quote), "Purchase Requisition No." = field("No."), "PO Creation Status" = const("Not Qualified")));
        }
        field(14; "Items Type ADCI"; Option)
        {
            Caption = 'Items Type';
            OptionMembers = " ","New","Existing";
            DataClassification = ToBeClassified;
        }
        field(15; "Existing Service ADCI"; Boolean)
        {
            Caption = 'Existing Service';
            DataClassification = ToBeClassified;
        }
        field(16; "Name_ADCI"; Text[50])
        {
            Caption = 'Name';
            DataClassification = ToBeClassified;
        }
        field(17; "Department BU ADCI"; Option)
        {
            Caption = 'Department / BU';
            OptionMembers = " ","IT","FINANCE","HR","PnP";
        }
    }
    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
        key(PK2; "Requested By")
        {

        }
        key(PK3; "Created By")
        {

        }
    }
    fieldgroups
    {
        fieldgroup(DropDown; "No.", Description, Status, "Requisition Type", "Requested By")
        {

        }
    }

    trigger OnInsert()
    begin
        GetPurchSetup();
        if "No." = '' then begin
            RecPnP.TestField("Purchase Requisition Nos.");
            "No." := NoSeriesMgt.GetNextNo(RecPnP."Purchase Requisition Nos.", WorkDate(), true);
        end;
        "Created By" := UserId;
        if "Requested By" = '' then
            "Requested By" := UserId;
    end;

    trigger OnDelete()
    var
        RecLines: Record "Purchase Requisition Line";
    begin
        Clear(RecLines);
        RecLines.SetRange("Document No.", "No.");
        if RecLines.FindSet() then
            RecLines.DeleteAll(true);
    end;

    procedure AssistEdit(OldPurchHeader: Record "Purchase Requisition Header"): Boolean
    begin
        GetPurchSetup();
        RecPnP.TestField("Purchase Requisition Nos.");
        if NoSeriesMgt.SelectSeries(RecPnP."Purchase Requisition Nos.", RecPnP."Purchase Requisition Nos.", RecPnP."Purchase Requisition Nos.") then begin
            NoSeriesMgt.SetSeries("No.");
            exit(true);
        end;
    end;

    local procedure GetPurchSetup()
    begin
        RecPnP.GET;
    end;

    var
        RecPnP: Record "Purchases & Payables Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
}
