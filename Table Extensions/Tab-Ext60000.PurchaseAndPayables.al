tableextension 60000 PurchaseAndPayables extends "Purchases & Payables Setup"
{
    fields
    {
        field(60000; "Purchase Requisition Nos."; Code[20])
        {
            Caption = 'Purchase Requisition Nos.';
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
    }
}
