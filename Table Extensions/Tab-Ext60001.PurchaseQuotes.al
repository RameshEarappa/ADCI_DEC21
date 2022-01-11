tableextension 60001 "Purchase Quotes" extends "Purchase Header"
{
    fields
    {
        field(60000; "Purchase Requisition No."; Code[20])
        {
            Caption = 'Purchase Requisition No.';
            DataClassification = ToBeClassified;
            TableRelation = "Purchase Requisition Header";
        }
        field(60001; "PO Creation Status"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = " ","PO Created","Not Qualified";
            Editable = false;
        }
    }
}
