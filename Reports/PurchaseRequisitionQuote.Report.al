report 60001 "Purchase Requisition Quote"
{
    DefaultLayout = RDLC;
    RDLCLayout = 'Reports\PurchaseRequisitionQuote.rdl';

    dataset
    {
        dataitem("Purchase Requisition Line"; "Purchase Requisition Line")
        {
            DataItemTableView = sorting("Document No.");
            RequestFilterFields = "Document No.";
            column(CompanyInfo_Picture; CompanyInfo.Picture) { }
            column(No_Header; PRHG."No.") { }
            column(Description_Header; PRHG.Description) { }
            column(Open_Purchase_Quotes; PRHG."Open Purchase Quotes") { }
            column(Requested_By; PRHG."Requested By") { }
            column(Required_By_Date; PRHG."Required By Date") { }
            column(Remarks; PRHG.Remarks) { }

            dataitem("Purchase Header"; "Purchase Header")
            {
                DataItemLink = "Purchase Requisition No." = FIELD("Document No.");
                DataItemLinkReference = "Purchase Requisition Line";
                column(Quote_No_; "No.") { }
                column(No_; PurchaseLineG."No.") { }
                column(Description; PurchaseLineG.Description) { }
                column(Vendor_No_; "Buy-from Vendor No.") { }
                column(Vendor_Name; "Buy-from Vendor Name") { }
                column(Quantity; PurchaseLineG.Quantity) { }
                column(Direct_Unit_Cost; PurchaseLineG."Direct Unit Cost") { }

                trigger OnAfterGetRecord()
                begin
                    Clear(PurchaseLineG);
                    PurchaseLineG.SetRange("Document Type", PurchaseLineG."Document Type"::Quote);
                    PurchaseLineG.SetRange("Document No.", "No.");
                    PurchaseLineG.SetRange("No.", "Purchase Requisition Line"."No.");
                    if PurchaseLineG.FindFirst() then;
                end;
            }
            trigger OnPreDataItem()
            begin
                Clear(PRHG);
                CompanyInfo.GET;
                CompanyInfo.CALCFIELDS(Picture);
            end;

            trigger OnAfterGetRecord()
            begin
                if PRHG.Get("Document No.") then
                    PRHG.CalcFields("Open Purchase Quotes");
            end;
        }
    }
    var
        CompanyInfo: Record "Company Information";
        PRHG: Record "Purchase Requisition Header";
        PurchaseLineG: Record "Purchase Line";
}