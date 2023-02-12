Import-Module .\apiObject.ps1

$method = 0 #GET
$url = "https://financialmodelingprep.com/"
$path = @("api/v3")
$apiKey = Get-Content -Path C:\script_auth\finModelKey.txt
$params = @($apiKey,"limit=1")
$params_noLimit = @($apiKey)
$params_limitless = @($apiKey,"limit=1000000000")
$params_btDates = @("from=2018-01-01",'to=2021-11-01',$apiKey)

$filepath = ".\"

<#ALL compaies
$company = "financial-statement-symbol-lists" 


$filename = 'companies.csv'
[apiObject]$companies = [apiObject]::new($method,$url,$path,$params)

$companies.InvokeRestMethod(0,$company)
#$companies.toCSV($filepath,$filename)
#>

<#Profile && sort industry
$cpyList = Import-Csv -Path "C:\Users\WinNe\OneDrive - University of New Mexico\Course Work\Fall 2021\MGMT 501 DataDrivnDecisions\Project\companies.csv"
$path2 = @("api/v3/profile")
$filename2 = "CompaniesSorted3.csv"
[apiIndustry]$companiesInd= [apiIndustry]::new($method,$url,$path2,$params)
foreach ($cpy in $cpyList)
{
   # $companiesInd.InvokeRestMethod(0,$cpy.Company)
    #$companiesInd.addtoCumulative()
}
#$companiesInd.toCSV($filepath,$filename2)
#$companiesInd.InvokeRestMethod(0,"AIMD")
#$companiesInd.addtoCumulative()
#$companiesInd.toCSV($filepath,$filename2)


#>
function create-data
{
    param
    (
        [apiObject]$apiObject,
        [array]$companies,
        [string]$filepath,
        [string]$filename
    )
    $total = 0
    $x = 0
    foreach ($company in $companies) 
    {
        $total++
        if($x -lt 280)
        {
            $x++
            if($x -ge 280) 
            {
                start-sleep -s 60
            } 
        }
        else{$x=1}
        
        $apiObject.InvokeRestMethod(0,$company.symbol)
        $apiObject.addtoCumulative()
        write-host $total    
    }
    $apiObject.toCSV($filepath,$filename)
    return $apiObject
}

function create-dataSN
{
    param
    (
        [apiObject]$apiObject,
        [array]$companies,
        [string]$filepath,
        [string]$filename
    )
    $total = 0
    $x = 0
    foreach ($company in $companies) 
    {
        $total++
        if($x -lt 280)
        {
            $x++
            if($x -ge 280) 
            {
                start-sleep -s 60
            } 
        }
        else{$x=1}
        
        $apiObject.InvokeRestMethod(0,$company.symbol)
        $date = [datetime]$company.date
        $apiObject.FormatResponse($date)
        write-host $total    
    }
    $apiObject.toCSV($filepath,$filename)
    return $apiObject
}

function create-dataSP
{
    param
    (
        [apiObject]$apiObject,
        [array]$companies,
        [string]$filepath,
        [string]$filename
    )
    $total = 0
    $x = 0
    foreach ($company in $companies) 
    {
        $total++
        if($x -lt 280)
        {
            $x++
            if($x -ge 280) 
            {
                start-sleep -s 60
            } 
        }
        else{$x=1}
        
        $apiObject.InvokeRestMethod(0,$company.symbol)
        $date = [datetime]$company.date
        $apiObject.FormatResponse($company.symbol,$date)
        write-host $total    
    }
    $apiObject.toCSV($filepath,$filename)
    return $apiObject
}

function create-dataAppend
{
    param
    (
        [apiObject]$apiObject,
        [array]$companies,
        [string]$filepath,
        [string]$filename
    )
    $total = 0
    $x = 0
    foreach ($company in $companies) 
    {
        $total++
        if($x -lt 280)
        {
            $x++
            if($x -ge 280) 
            {
                start-sleep -s 30
            } 
        }
        else{$x=1}
        $apiObject.InvokeRestMethod(0,$company.symbol)
        
        if($apiObject.formattedResponse)
        {
            $apiObject.toCSV($filepath,$filename)
            write-host $total
        }
        else
        {
            write-host $total " is null"
        }     
    }
}

function create-dataSentAppend
{
    param
    (
        [apiObject]$apiObject,
        [array]$companies,
        [string]$filepath,
        [string]$filename
    )
    $total = 0
    $x = 0
    foreach ($company in $companies) 
    {
        $total++
        if($x -lt 280)
        {
            $x++
            if($x -ge 280) 
            {
                start-sleep -s 10
            } 
        }
        else{$x=1}
        $symbol = $company.symbol
        $date = $company.date
        $apiObject.InvokeRestMethod(0,$symbol,$date)
        
        if($apiObject.formattedResponse)
        {
            $apiObject.toCSV($filepath,$filename)
            write-host $total
        }
        else
        {
            write-host $total " is null"
        }     
    }
}

#$path3 = @("api/v4/standard_industrial_classification")
#[apiSIC]$sic = [apiSIC]::new($method,$url,$path3,$params)
#$sic.InvokeRestMethod(0,"all")
#$sic.toCSV($filepath,"sic.csv")
#$sic.getCompanies()
#$companies = $sic.companies
$companies = Import-csv C:\Users\WinNe\OneDrive' - University of New Mexico'\'Course Work'\'Fall 2021'\'MGMT 501 DataDrivnDecisions'\Project\Company2.csv

#Income Statement

$isPath = @("api/v3/income-statement")
[apiObject]$income = [apiObject]::new($method,$url,$isPath,$params)
#$income = create-data -apiObject $income -companies $companies -filepath $filepath -filename income.csv

#Balance Sheet
$bsPath = @("api/v3/balance-sheet-statement")
[apiObject]$balance = [apiObject]::new($method,$url,$bsPath,$params)
#$balance = create-data -apiObject $balance -companies $companies -filepath $filepath -filename balance.csv


#Cash FLow
$cfPath = @("api/v3/cash-flow-statement")
[apiObject]$cash = [apiObject]::new($method,$url,$cfPath,$params)
#$cash = create-data -apiObject $cash -companies $companies -filepath $filepath -filename cashFlow.csv

#Full--asReported
#$fullPath = @("api/v3/financial-statement-full-as-reported")
#[apiObject]$full = [apiObject]::new($method,$url,$fullPath,$params_noLimit)
#$full = create-data -apiObject $full -companies $companies -filepath $filepath -filename FullAsReported.csv


#Enterprise Values
$evPath = @("api/v3/enterprise-values")
[apiObject]$entValue = [apiObject]::new($method,$url,$evPath,$params)
#$entValue = create-data -apiObject $entValue -companies $companies -filepath $filepath -filename enterpriseValues.csv

#financial growth
$fgPath = @("api/v3/financial-growth")
[apiObject]$finGrowth = [apiObject]::new($method,$url,$fgPath,$params)
#$finGrowth = create-data -apiObject $finGrowth -companies $companies -filepath $filepath -filename financialGrowth.csv

#FG-Balancesheet
$fgPath_bs = @("api/v3/balance-sheet-statement-growth")
[apiObject]$finGrowthBS = [apiObject]::new($method,$url,$fgPath_bs,$params)
#$finGrowthBS = create-data -apiObject $finGrowthBS -companies $companies -filepath $filepath -filename financialGrowthBS.csv

#FG-IncomeStatement
$fgPath_is = @("api/v3/income-statement-growth")
[apiObject]$finGrowthIS = [apiObject]::new($method,$url,$fgPath_is,$params)
#$finGrowthIS = create-data -apiObject $finGrowthIS -companies $companies -filepath $filepath -filename financialGrowthIS.csv

#Stock Rating
<#This would take too much coding to collect skipping for now#>

#Company Profile--FT Employees
$cpPath = @("api/v3/profile")
[apiObject]$cProfile = [apiObject]::new($method,$url,$cpPath,$params)
#$cProfile = create-data -apiObject $cProfile -companies $companies -filepath $filepath -filename cProfile.csv

#KeyExecutives
$kePath = @("api/v3/key-executives")
[apiKeyExecs]$kExecs = [apiKeyExecs]::new($method,$url,$kePath,$params)
#$kExecs = create-dataAppend -apiObject $kExecs -companies $companies -filepath $filepath -filename keyExecs.csv

#sentiment
#$companies2 = Import-Csv -Path C:\Users\WinNe\OneDrive' - University of New Mexico'\'Course Work'\'Fall 2021'\'MGMT 501 DataDrivnDecisions'\Project\fsDate.csv
#$data = $companies2 |
#    select-object   @{Name="symbol" ; Expression = {$_.symbol}},
#                    @{Name="date" ; Expression = {[DateTime]$_.date}}
$sentPath = @("api/v4/historical/social-sentiment")
#records do not extend back to FS periods
[apiSentiment]$sentiment = [apiSentiment]::new($method,$url,$sentPath,$params_limitless)
#$sentiment = create-dataSP -apiObject $sentiment -companies $companies -filepath $filepath -filename sentiment.csv
#NOT--works but not enough date into periods
#pressRelaeaase
$prPath = @("api/v3/press-releases")
[apiPress]$press = [apiPress]::new($method,$url,$prPath,$params_limitless)
#create-dataSentAppend -apiObject $press -companies $data -filepath $filepath -filename press.csv
#NOT
#stock price
$spPath = @("api/v3/historical-price-full")
[datetime]$fsDate = '6/30/2021'
[apiStockPrice]$stockPrice = [apiStockPrice]::new($method,$url,$spPath,$params_btDates)
#$stockPrice.InvokeRestMethod(0,'AAPL')
#$stockPrice.FormatResponse('AAPL',$fsDate)
$stockPrice = create-dataSP -apiObject $stockPrice -companies $companies -filepath $filepath -filename stockPrice2.csv

#stock news
$snPath = @("api/v3/stock_news")
[apiStockNews]$stockNews = [apiStockNews]::new($method,$url,$snPath,$params_limitless)
#$stockNews = create-dataSN -apiObject $stockNews -companies $companies -filepath $filepath -filename stocknews.csv