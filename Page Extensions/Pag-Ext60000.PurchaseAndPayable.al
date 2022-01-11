pageextension 60000 PurchaseAndPayable extends "Purchases & Payables Setup"
{
    layout
    {
        addlast("Number Series")
        {
            field("Purchase Requisition Nos."; Rec."Purchase Requisition Nos.")
            {
                ApplicationArea = All;
            }
        }
    }
}
