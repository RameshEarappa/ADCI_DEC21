table 60001 "Purchase Requisition Line"
{
    Caption = 'Purchase Requisition Line';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = ToBeClassified;
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = ToBeClassified;
        }
        field(3; "Type"; Option)
        {
            Caption = 'Type';
            DataClassification = ToBeClassified;
            OptionMembers = Item,"G/L Account","Fixed Asset";

            trigger OnValidate()
            var
                TempReqisitionLine: Record "Purchase Requisition Line" temporary;
            begin
                if Type <> xRec.Type then begin
                    TempReqisitionLine := Rec;
                    Init();
                    SystemId := TempReqisitionLine.SystemId;
                    Type := TempReqisitionLine.Type;
                end;
            end;
        }
        field(4; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = ToBeClassified;
            TableRelation = IF (Type = CONST("G/L Account")) "G/L Account" WHERE("Direct Posting" = CONST(true), "Account Type" = CONST(Posting), Blocked = CONST(false))
            ELSE
            IF (Type = CONST("Fixed Asset")) "Fixed Asset" where(Blocked = const(false))
            ELSE
            IF (Type = CONST(Item)) Item WHERE(Blocked = CONST(false), "Purchasing Blocked" = CONST(false));

            trigger OnValidate()
            begin
                if (Rec."No." <> '') AND (Rec."No." <> xRec."No.") then begin
                    ValidateNumber();
                end else
                    if Rec."No." = '' then begin
                        Description := '';
                        "Unit of Measure Code" := '';
                        "Direct Unit Cost" := 0;
                    end;
            end;
        }
        field(5; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = ToBeClassified;
        }
        field(6; "Item Category Code"; Code[20])
        {
            Caption = 'Item Category Code';
            DataClassification = ToBeClassified;
            TableRelation = "Item Category";
        }
        field(7; "Location Code"; Code[20])
        {
            Caption = 'Location Code';
            DataClassification = ToBeClassified;
            TableRelation = Location;
        }
        field(8; "Direct Unit Cost"; Decimal)
        {
            Caption = 'Direct Unit Cost';
            DataClassification = ToBeClassified;
        }
        field(9; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            DataClassification = ToBeClassified;
            TableRelation = "Item Unit of Measure".Code WHERE("Item No." = FIELD("No."));
        }
        field(10; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = ToBeClassified;
        }
        field(11; "Remarks"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(PK; "Document No.", "Line No.")
        {
            Clustered = true;
        }
    }
    fieldgroups
    {
        fieldgroup(DropDown; "No.", Description, "Direct Unit Cost", Quantity, "Unit of Measure Code")
        {
        }
    }

    procedure ValidateNumber()
    var
        RecItem: Record Item;
        RecGlAccount: Record "G/L Account";
        RecFA: Record "Fixed Asset";
    begin
        case Rec.Type of
            Rec.Type::Item:
                begin
                    RecItem.GET(Rec."No.");
                    Description := RecItem.Description;
                    "Item Category Code" := RecItem."Item Category Code";
                    "Unit of Measure Code" := RecItem."Purch. Unit of Measure";
                    "Direct Unit Cost" := RecItem."Unit Cost";

                end;
            Rec.Type::"G/L Account":
                begin
                    RecGlAccount.GET("No.");
                    Description := RecGlAccount.Name;
                end;
            Rec.Type::"Fixed Asset":
                begin
                    RecFA.GET("No.");
                    Description := RecFA.Description;
                end;
        end;
    end;
}
