enum Method 
{
    GET     = 0
    POST    = 1     
}
class apiInterface
{#interface class/cannot be directly instanciated
    [string]            $url
    [array]             $path
    [string]            $method
    [hashtable]         $headers
    [string]            $body
    [array]             $params
    [PSCustomObject]    $response

    [void]hidden init()
    {#hidden helper method for overloaded constructor
        $this.init($null,$null,$null,$null,$null,$null)
    }

    [void]hidden init([int]$method)
    {#hidden helper method for overloaded constructor
        $this.init($method,$null,$null,$null,$null,$null)
    }

    [void]hidden init([int]$method,[string]$url)
    {#hidden helper method for overloaded constructor
        $this.init($method,$url,$null,$null,$null,$null)
    }

    [void]hidden init([int]$method,[string]$url,[array]$path)
    {#hidden helper method for overloaded constructor
        $this.init($method,$url,$path,$null,$null,$null)
    }

    [void]hidden init([int]$method,[string]$url,[array]$path,[array]$params)
    {#hidden helper method for overloaded constructor
        $this.init($method,$url,$path,$params,$null,$null)
    }

    [void]hidden init([int]$method,[string]$url,[array]$path,[array]$params,[hashtable]$headers)
    {#hidden helper method for overloaded constructor
        $this.init($method,$url,$path,$params,$headers,$null)
    }

    [void]hidden init([int]$method,[string]$url,[array]$path,[array]$params,[hashtable]$headers,[string]$body)
    {#hidden helper method for overloaded constructor
        $this.method        = ([Method]$method.ToString())
        $this.url           = $url
        $this.path          = $path
        $this.params        = $params
        $this.headers       = $headers
        $this.body          = $body
    }

    apiInterface()
    {#Constructor--default object no values set
        $type = $this.GetType()
        if ($type -eq [apiInterface]){throw("Cannot create an instance of an interface")}
        else {
            {
                $this.init()
            }
        }
    }
   
    apiInterface([int]$method)
    {#Constructor--only $method argument passed
        $type = $this.GetType()
        if ($type -eq [apiInterface]){throw("Cannot create an instance of an interface")}
        else {
            {
                $this.init($method)
            }
        }
    }

    apiInterface([int]$method,[string]$url)
    {#Constructor--only $method and $url arguments passed
        $type = $this.GetType()
        if ($type -eq [apiInterface]){throw("Cannot create an instance of an interface")}
        else {
            {
                $this.init($method,$url)
            }
        }
    }

    apiInterface([int]$method,[string]$url,[array]$path)
    {#Constructor--only $method, $url, and $path arguments passed
        $type = $this.GetType()
        if ($type -eq [apiInterface]){throw("Cannot create an instance of an interface")}
        else {
            {
                $this.init($method,$url,$path)
            }
        }
    }

    apiInterface([int]$method,[string]$url,[array]$path,[array]$params)
    {#Constructor--only $method, $url, $path, and $params arguments passed
        $type = $this.GetType()
        if ($type -eq [apiInterface]){throw("Cannot create an instance of an interface")}
        else {
            {
                $this.init($method,$url,$path,$params)
            }
        }
    }

    apiInterface([int]$method,[string]$url,[array]$path,[array]$params,[hashtable]$headers)
    {#Constructor--only $method, $url, $path, $params, and $headers passed
        $type = $this.GetType()
        if ($type -eq [apiInterface]){throw("Cannot create an instance of an interface")}
        else {
            {
                $this.init($method,$url,$path,$params,$headers)
            }
        }
    }

    apiInterface([int]$method,[string]$url,[array]$path,[array]$params,[hashtable]$headers,[string]$body)
    {#Constructor--all object arguments passed 
        $type = $this.GetType()
        if ($type -eq [apiInterface]){throw("Cannot create an instance of an interface")}
        else {
            {
                $this.init($method,$url,$path,$params,$headers,$body)
            }
        }
    }

    [void] InvokeRestMethod()
    {#abstract-method: will throw error if not overridden in child class
        Write-Host "InvokeRestMethod must be overridden in sub-class"
        throw("InvokeRestMethod must be overridden in sub-class")
    }

    [void] setMethod([int]$method)
    {#to set/reset $this.method
        $this.method = ([Method]$method.ToString())
    }

    [void]setURL([string]$url)
    {#to set/reset $this.url
        $this.url = $url
    }

    [void]setPath([array]$path)
    {#to set/reset $this.path
        $this.path = $path
    }

    [void]addPath([string]$path)
    {#to add new path to [array]$this.path
        $this.path += @($path)
    }

    [void]setParams([array]$params)
    {#to set/reset $this.params
        $this.params = $params
    }

    [void]setHeaders([hashtable]$headers)
    {#to set/reset $this.headers
        $this.headers = $headers
    }

    [void]setBody([string]$body)
    {#to set/reset $this.body
        $this.body = $body
    }
}#END INTERFACE Class

class apiObject :apiInterface
{#Generic API Object class
    [array]$cumulativeResponse

    apiObject([int]$method,[string]$url,[array]$path,[array]$params) : base($method,$url,$path,$params)
    {<#(method,url,path,prams)--all arguments passed to interface#>
        $this.init($method,$url,$path,$params)
    }

    apiObject([int]$method,[string]$url,[array]$path,[array]$params,[hashtable]$headers) : base($method,$url,$path,$params,$headers)
    {<#(method,url,path,prams,headers)--all arguments passed to interface#>}

    apiObject([int]$method,[string]$url,[array]$path,[array]$params,[hashtable]$headers,[string]$body) : base($method,$url,$path,$params,$headers,$body)
    {<#(method,url,path,prams,headers,body)--all arguments passed to interface#>}

    [string]hidden addParams()
    {#to add $this.params array to fully-qualified-path 
        $tmpString = $null
        foreach ($param in $this.params)
        {
            if ($param -eq $this.params[0])
            {$tmpString += "?$param"}
            else
            {$tmpString += "&$param"}
        }
        return $tmpString
    }
    
    [string]hidden getFullURL([int]$path,[string]$company)
    {#to generate fully-qualified URL (URL/path/company?params&n)
        $tmpString = $this.url+$this.path[$path]+'/'+$company+$this.addParams()
        return $tmpString
    }

    [void] InvokeRestMethod([int]$path,[string]$company)
    {#Override abstract method from interface
        if ($null -eq $this.method)
        {
            throw("API method GET(0)/POST(1) must be set before Invoking a REST method")
        }

        $url_path_company_params = $this.getFullURL($path,$company)
        if (('' -ne $this.body) -and ('' -ne $this.headers))
        {
            $this.response = Invoke-RestMethod $url_path_company_params -Method $this.method -Headers $this.headers -Body $this.body 
        }
        elseif ('' -ne $this.headers)
        {
            $this.response = Invoke-RestMethod $url_path_company_params -Method $this.method -Headers $this.headers 
        }
        else
        {
            $this.response = Invoke-RestMethod $url_path_company_params -Method $this.method
        }
    }

    [void]toCSV([string]$path,[string]$filename)
    {#to export API response to CSV file
        $tempTable = @()
        #foreach ($item in $this.cumulativeResponse)  
         #   {
          #      $tempTable+=[PSCustomObject]@{"Company" = $item}
           # }
        
#        ForEach ($item in $tempTable)
#        {
#            $company = [PSCustomObject]@{'Company' = $item.company}
#            $company | Export-Csv $path\$filename -Append -NoTypeInformation -Force
#        }
        $this.cumulativeResponse | Export-Csv -Path $path'\'$filename -NoTypeInformation -Force

    }

    [void]addtoCumulative()
    {
        $this.cumulativeResponse += $this.response
    }
}

class apiIndustry :apiObject
{#Generic API Object class
    [array]$cumulativeResponse

    apiIndustry([int]$method,[string]$url,[array]$path,[array]$params) : base($method,$url,$path,$params)
    {<#(method,url,path,prams)--all arguments passed to interface#>
        $this.init($method,$url,$path,$params)
    }

    [PSCustomObject]hidden formatResponse()
    {
        $tempTable = @()
        $industry = $this.response.industry
        $industry -match '(\w*)(\W+)(\w*)'
        if($matches.Count -gt 1)
        {
            $tempTable =[PSCustomObject]@{  "company"   = $this.response.symbol
                                            "industry"  = $Matches[1]+' '+$Matches[3]}
        }
        else 
        {
            $tempTable =[PSCustomObject]@{  "company"   = $this.response.symbol
                                            "industry"  = $industry}
        }
        return $tempTable
    }

    [void]addtoCumulative()
    {
        $this.cumulativeResponse += $this.formatResponse()
    }

    [void]toCSV([string]$path,[string]$filename)
    {
        $this.cumulativeResponse | Export-Csv -Path $path'\'$filename -NoTypeInformation -Force
        #$this.cumulativeResponse | Export-Csv $path'\'$filename -NoType
        #$lines=Get-Content temp.csv | %{$_ -replace '"',''}
        #$lines | Out-File final.csv -Encoding Unicode

    }
}
class apiSIC :apiObject
{
    [array]$companies
    apiSIC([int]$method,[string]$url,[array]$path,[array]$params) : base($method,$url,$path,$params)
    {<#(method,url,path,prams)--all arguments passed to interface#>
        $this.init($method,$url,$path,$params)
    }

    [void]getCompanies()
    {
        #$this.companies = $this.response |
            #Select-Object   @{Name="symbol" ; Expression={$_.symbol} }
        for ($x = 0; $x -lt $this.response.Length; $x++)
        {
            $this.companies += @($this.response[$x].symbol)
        }
    }
    

    [void]toCSV([string]$path,[string]$filename)
    {
        $this.response | Export-Csv -Path $path'\'$filename -NoTypeInformation -Force
    }
}
class apiKeyExecs:apiObject
{
    [array]$formattedResponse
    apiKeyExecs([int]$method,[string]$url,[array]$path,[array]$params) : base($method,$url,$path,$params)
    {<#(method,url,path,prams)--all arguments passed to interface#>
        $this.init($method,$url,$path,$params)
    }

    [void] InvokeRestMethod([int]$path,[string]$company)
    {#Override abstract method from apiObject
        if ($null -eq $this.method)
        {
            throw("API method GET(0)/POST(1) must be set before Invoking a REST method")
        }

        $url_path_company_params = $this.getFullURL($path,$company)
        if (('' -ne $this.body) -and ('' -ne $this.headers))
        {
            $this.response = Invoke-RestMethod $url_path_company_params -Method $this.method -Headers $this.headers -Body $this.body
            $this.FormatResponse($company) 
        }
        elseif ('' -ne $this.headers)
        {
            $this.response = Invoke-RestMethod $url_path_company_params -Method $this.method -Headers $this.headers
            $this.FormatResponse($company) 
        }
        else
        {
            $this.response = Invoke-RestMethod $url_path_company_params -Method $this.method
            $this.FormatResponse($company)
        }
    }

    [void] hidden FormatResponse([string]$company)
    {
        $this.formattedResponse = $null
        for($x=0;$x -lt $this.response.length;$x++)
            {
                $this.formattedResponse += [PSCustomObject] @{  "Company"       = $company 
                                                                "title"         = $this.response[$x].title
                                                                "name"          = $this.response[$x].name
                                                                "pay"           = $this.response[$x].pay
                                                                "currency"      = $this.response[$x].currency
                                                                "gender"        = $this.response[$x].gender
                                                                "yearBorn"      = $this.response[$x].yearBorn
                                                                "titleSince"    = $this.response[$x].titleSince}
            }
            
    }

    [void]toCSV([string]$path,[string]$filename)
    {
        $this.formattedResponse | Export-Csv -Path $path'\'$filename -NoTypeInformation -Force -Append

    }
}

class apiSentiment:apiObject
{
    [array]$formattedResponse
    [array]$tmpResponse
    
    apiSentiment([int]$method,[string]$url,[array]$path,[array]$params) : base($method,$url,$path,$params)
    {<#(method,url,path,prams)--all arguments passed to interface#>
        $this.init($method,$url,$path,$params)
    }

    [string]hidden getFullURL([int]$path,[string]$company)
    {#to generate fully-qualified URL (URL/path/company?params&n)
        $tmpString = $this.url+$this.path[$path]+'?'+$company+$this.addParams()
        return $tmpString
    }

    [string]hidden addParams()
    {#to add $this.params array to fully-qualified-path 
        $tmpString = $null
        foreach ($param in $this.params)
        {
            if ($param -eq $this.params[0])
            {$tmpString += "&$param"}
            else
            {$tmpString += "&$param"}
        }
        return $tmpString
    }

    [void] InvokeRestMethod([int]$path,[string]$company)
    {#Override abstract method from apiObject
        if ($null -eq $this.method)
        {
            throw("API method GET(0)/POST(1) must be set before Invoking a REST method")
        }

        $url_path_company_params = $this.getFullURL($path,"symbol="+$company)
        write-host $url_path_company_params
        if (('' -ne $this.body) -and ('' -ne $this.headers))
        {
            $this.response = Invoke-RestMethod $url_path_company_params -Method $this.method -Headers $this.headers -Body $this.body
            #$this.FormatResponse($company,$date)
        }
        elseif ('' -ne $this.headers)
        {
            $this.response = Invoke-RestMethod $url_path_company_params -Method $this.method -Headers $this.headers
            #$this.FormatResponse($company,$date) 
        }
        else
        {
            $this.response = Invoke-RestMethod $url_path_company_params -Method $this.method
            #$this.FormatResponse("symbol="+$company,$date)
        }
    }

    [void] FormatResponse([string]$company,[DateTime]$date)
    {
        $this.tmpResponse = @()
        $this.tmpResponse = $this.response | Select-Object @{Name="date" ;                      Expression = {[datetime]$_.date}},
                                                            @{Name='symbol' ;                   Expression = {$_.symbol}},
                                                            @{Name = 'stocktwitsPosts' ;        Expression = {[int]$_.stocktwitsPosts}},
                                                            @{Name='twitterPosts' ;             Expression = {[int]$_.twitterPosts}},
                                                            @{Name='stocktwitsComments' ;       Expression = {[int]$_.stocktwitsComments}},
                                                            @{Name='twitterComments' ;          Expression = {[int]$_.twitterComments}},
                                                            @{Name='stocktwitsLikes' ;          Expression = {[int]$_.stocktwitsLikes}},
                                                            @{Name='twitterLikes' ;             Expression = {[int]$_.twitterLikes}},
                                                            @{Name='stocktwitsImpressions' ;    Expression = {[int]$_.stocktwitsImpressions}},
                                                            @{Name='twitterImpressions' ;       Expression = {[int]$_.twitterImpressions}}
        
        foreach($record in $this.tmpResponse)
        {
            if( ($record.date -gt $date.AddYears(-1)) -and ($record.date -lt $date) )
            {
                $this.formattedResponse+= $record
            }
        }
            
    }
    
    [void]toCSV([string]$path,[string]$filename)
    {
        $this.formattedResponse | Export-Csv -Path $path'\'$filename -NoTypeInformation -Force

    }
}

class apiPress:apiObject
{
    [array]$formattedResponse
    
    apiPress([int]$method,[string]$url,[array]$path,[array]$params) : base($method,$url,$path,$params)
    {<#(method,url,path,prams)--all arguments passed to interface#>
        $this.init($method,$url,$path,$params)
    }

    [void] InvokeRestMethod([int]$path,[string]$company,[DateTime]$date)
    {#Override abstract method from apiObject
        if ($null -eq $this.method)
        {
            throw("API method GET(0)/POST(1) must be set before Invoking a REST method")
        }

        $url_path_company_params = $this.getFullURL($path,$company)
        write-host $url_path_company_params
        if (('' -ne $this.body) -and ('' -ne $this.headers))
        {
            $this.response = Invoke-RestMethod $url_path_company_params -Method $this.method -Headers $this.headers -Body $this.body
            $this.FormatResponse($company,$date)
        }
        elseif ('' -ne $this.headers)
        {
            $this.response = Invoke-RestMethod $url_path_company_params -Method $this.method -Headers $this.headers
            $this.FormatResponse($company,$date) 
        }
        else
        {
            $this.response = Invoke-RestMethod $url_path_company_params -Method $this.method
            $this.FormatResponse($company,$date)
        }
    }

    [void] hidden FormatResponse([string]$company,[DateTime]$date)
    {
        $this.formattedResponse = $null
        $begin = $date.AddMonths(-12)
        $this.formattedResponse = $this.response | Where-Object {($_.date -ge $begin) -and ($_.date -le $date)}
            
    }
    
    [void]toCSV([string]$path,[string]$filename)
    {
        $this.formattedResponse | Export-Csv -Path $path'\'$filename -NoTypeInformation -Force -Append

    }
}

class apiStockPrice:apiObject
{
    [array]$formattedResponse
    [array]$tmpResponse

    apiStockPrice([int]$method,[string]$url,[array]$path,[array]$params) : base($method,$url,$path,$params)
    {<#(method,url,path,prams)--all arguments passed to interface#>
        $this.init($method,$url,$path,$params)
    }

    [void] FormatResponse([string]$company,[DateTime]$date)
    {
        $this.tmpResponse = @()
        $this.tmpResponse = $this.response.historical | Select-Object   @{Name="date" ; Expression = {[datetime]$_.date}},@{Name='adjClose' ; Expression = {$_.adjClose}}#>

        #$this.formattedResponse = @()
        $avgAdjClose = 0
        $count = 0

        foreach ($record in $this.tmpResponse)
        {
            if ( ($record.date -gt $date.AddYears(-1)) -and ($record.date -lt $date)) 
            {
                $avgAdjClose+=$record.adjClose
                $count++
            }else 
            {
                continue    
            }
        }

       $avgAdjClose2 = 0
        $count2 = 0

        foreach ($record in $this.tmpResponse)
        {
            if ( ($record.date -gt $date.AddYears(-2)) -and ($record.date -lt $date.AddYears(-1)) )
            {
                $avgAdjClose2+=$record.adjClose
                $count2++
            }else 
            {
                continue    
            }
        }

        try {$avgAdjClose = $avgAdjClose/$count}
            catch {Write-Host "$company zero"}
        try {$avgAdjClose2 = $avgAdjClose2/$count2}
            catch {Write-Host "$company zero"}

        $this.formattedResponse+=[PSCustomObject]   @{
                                                        'company'           = $company
                                                        'year'              = $date.year
                                                        'avgAdjClosePre'    = $avgAdjClose2
                                                        'avgAdjClose'       = $avgAdjClose
                                                        }
        
    }
    
    [void]toCSV([string]$path,[string]$filename)
    {
        $this.formattedResponse | Export-Csv -Path $path'\'$filename -NoTypeInformation -Force 

    }
}

class apiStockNews:apiObject
{
    [array]$formattedResponse
    [array]$tmpResponse


    apiStockNews([int]$method,[string]$url,[array]$path,[array]$params) : base($method,$url,$path,$params)
    {<#(method,url,path,prams)--all arguments passed to interface#>
        $this.init($method,$url,$path,$params)
    }

    [void]FormatResponse([DateTime]$date)
    {
        $this.tmpResponse = $this.response | Select-Object      @{Name="symbol" ; Expression = {$_.symbol}},
                                                                @{Name="site" ; Expression = {$_.site}},
                                                                @{Name="url" ; Expression = {$_.url}},
                                                                @{Name='publishedDate' ; Expression = {[datetime]$_.publishedDate}},
                                                                @{Name='title' ; Expression = {$_.title}},
                                                                @{Name='text' ; Expression = {$_.text}}
        foreach($record in $this.tmpResponse)
        {
            if( ($record.publishedDate -gt $date.addYears(-1)) -and ($record.publishedDate -lt $date) )
            {
                $this.formattedResponse+= $record
            }
        }
    }

    [string]hidden addParams()
    {#to add $this.params array to fully-qualified-path 
        $tmpString = $null
        foreach ($param in $this.params)
        {
            if ($param -eq $this.params[0])
            {$tmpString += "&$param"}
            else
            {$tmpString += "&$param"}
        }
        return $tmpString
    }
    
    [string]hidden getFullURL([int]$path,[string]$company)
    {#to generate fully-qualified URL (URL/path/company?params&n)
        $tmpString = $this.url+$this.path[$path]+'?tickers='+$company+$this.addParams()
        return $tmpString
    }

    [void]toCSV([string]$path,[string]$filename)
    {#to export API response to CSV file
        $this.formattedResponse | Export-Csv -Path $path'\'$filename -NoTypeInformation -Force

    }
}