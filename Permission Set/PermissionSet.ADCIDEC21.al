permissionset 60000 "ADCI-DEC21"
{
    Assignable = true;
    Caption = 'ADCI-DEC21';
    Permissions =
        table "Purchase Requisition Header" = X,
        tabledata "Purchase Requisition Header" = RMID,
        table "Purchase Requisition Line" = X,
        tabledata "Purchase Requisition Line" = RMID,
        page "Purchase Requisitions" = X,
        page "Purchase Requisition" = X,
        table "Purchase Quote Header" = X,
        tabledata "Purchase Quote Header" = RIMD,
        table "Purchase Quote Lines" = X,
        tabledata "Purchase Quote Lines" = RIMD,
        page "Purch. Quotes converted to PO" = X,
        Page "Purchase Quotes Subform" = X,
        page "Purchase Quote converted to PO" = X,
          page "Purch. Quotes Not Qualified" = X,
        Page "Purchase Quote Not Qualified" = X,
        page "Purchase Quotes NQ Subform" = X;


}
