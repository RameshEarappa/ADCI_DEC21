report 60000 "Pro Requisition Control Form"
{
    Caption = 'Purchase Requisitions';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultLayout = RDLC;
    RDLCLayout = 'Reports\ProcurementRequisition.rdl';

    dataset
    {
        dataitem("Purchase Requisition Header"; "Purchase Requisition Header")
        {
            DataItemTableView = SORTING("No.");
            RequestFilterFields = "No.";
            CalcFields = "Open Purchase Quotes", "Purch. Quotes converted to PO", "Purchase Quotes Not Qualified";
            column(CompanyInfo_Picture; CompanyInfo.Picture) { }
            column(No_; "No.") { }
            column(SetNew; SetNew) { }
            column(SetExisiting; SetExisiting) { }
            column(SetExisitingService1; SetExisitingService1) { }
            column(SetExisitingService2; SetExisitingService2) { }
            column(Name_ADCI; Name_ADCI) { }
            column(Department_BU_ADCI; "Department BU ADCI") { }
            column(HeaderRemarks; Remarks) { }
            column(NumberOfQuotations; NumberOfQuotations) { }
            column(SetComparison; SetComparison1) { }
            column(SetComparison2; SetComparison2) { }
            column(bool; bool) { }
            column(SystemCreatedAt; DT2DATE(SystemCreatedAt)) { }
            dataitem("Purchase Requisition Line"; "Purchase Requisition Line")
            {
                DataItemLink = "Document No." = FIELD("No.");
                DataItemLinkReference = "Purchase Requisition Header";
                column(Description; Description) { }
                column(Quantity; Quantity) { }
                column(Unit_of_Measure_Code; "Unit of Measure Code") { }
                column(Remarks; Remarks) { }
            }
            trigger OnPreDataItem()
            begin
                CompanyInfo.GET;
                CompanyInfo.CALCFIELDS(Picture);
            end;

            trigger OnAfterGetRecord()
            begin
                SetComparison1 := false;
                SetComparison2 := false;
                SetNew := false;
                SetExisiting := false;
                SetExisitingService1 := false;
                SetExisitingService2 := false;
                NumberOfQuotations := 0;
                NumberOfQuotations := "Open Purchase Quotes" + "Purch. Quotes converted to PO" + "Purchase Quotes Not Qualified";
                if NumberOfQuotations <= 1 then
                    SetComparison1 := true
                else
                    SetComparison2 := true;

                if "Items Type ADCI" = "Items Type ADCI"::New then
                    SetNew := true
                else
                    SetExisiting := true;

                if "Existing Service ADCI" then
                    SetExisitingService1 := true
                else
                    SetExisitingService2 := true;
            end;
        }
    }
    var
        CompanyInfo: Record "Company Information";
        NumberOfQuotations: Integer;
        SetComparison1: Boolean;
        SetComparison2: Boolean;
        bool: Boolean;
        SetNew: Boolean;
        SetExisiting: Boolean;
        SetExisitingService1: Boolean;
        SetExisitingService2: Boolean;
}