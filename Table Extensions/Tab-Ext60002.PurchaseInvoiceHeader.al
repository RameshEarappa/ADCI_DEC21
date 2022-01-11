tableextension 60002 "Purchase Invoice Header" extends "Purch. Inv. Header"
{
    fields
    {
        field(60000; "Purchase Requisition No."; Code[20])
        {
            Caption = 'Purchase Requisition No.';
            DataClassification = ToBeClassified;
            TableRelation = "Purchase Requisition Header";
        }
    }
}
