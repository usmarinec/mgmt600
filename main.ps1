Import-Module .\apiObject.ps1

$method = 0 #GET
$url = "https://financialmodelingprep.com/"
$path = @("api/v3")
$apiKey = Get-Content -Path C:\script_auth\finModelKey.txt
$params = @($apiKey,"limit=1")
$params_noLimit = @($apiKey)
$params_limitless = @($apiKey,"limit=1000000000")

$filepath = ".\script_output"

#ALL compaies
<# $company = "financial-statement-symbol-lists" 


$filename = 'companies.csv'
[apiObject]$companies = [apiObject]::new($method,$url,$path,$params)

$companies.InvokeRestMethod(0,$company)
$companies.addtoCumulative()
$companies.toCSV($filepath,$filename)
 #>


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

#stock news
$companies = Import-csv ".\companies.csv"
$snPath = @("api/v3/stock_news")
[apiStockNews]$stockNews = [apiStockNews]::new($method,$url,$snPath,$params_limitless)
$stockNews = create-dataSN -apiObject $stockNews -companies $companies -filepath $filepath -filename stocknews.csv