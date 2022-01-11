pageextension 60001 "Purchase Quotes" extends "Purchase Quote"
{
    layout
    {
        addlast(General)
        {
            field("Purchase Requisition No."; Rec."Purchase Requisition No.")
            {
                ApplicationArea = All;
                Editable = false;
            }
            field("PO Creation Status"; Rec."PO Creation Status")
            {
                ApplicationArea = All;
                Editable = false;
            }
        }
    }
}
