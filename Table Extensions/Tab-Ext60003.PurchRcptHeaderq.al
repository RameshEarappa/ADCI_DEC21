tableextension 60003 "Purch. Rcpt. Headerq" extends "Purch. Rcpt. Header"
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
