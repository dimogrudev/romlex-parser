$output = "D:\GitHub\romlex-parser\dictionaries";

$letters = 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l',
	'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z';
$dialects = @{
	'rmcb' = ('en', 'de');
	'rmcd' = ('en', 'de', 'sl');
	'rmce' = ('en', 'de', 'cs', 'sk');
	'rmcr' = ('en', 'de', 'hu');
	'rmcp' = ('en', 'de', 'sl');
	'rmcs' = ('en', 'de', 'hu');
	'rmcv' = ('en', 'de', 'hu');
	'rmff' = ('en', 'de', 'fi', 'sv');
	'rmna' = ('en', 'de', 'mk');
	'rmnb' = ('en', 'de', 'mk');
	'rmnc' = ('en', 'ru');
	'rmne' = ('en', 'de', 'bg');
	'rmnk' = ('en', 'de', 'sr', 'sq');
	'rmns' = ('en', 'de');
	'rmnu' = ('en', 'de', 'ro');
	'rmoo' = ('en', 'de', 'fr');
	'rmww' = ('en', 'de');
	'rmyb' = ('en', 'de' ,'sr');
	'rmyd' = ('en', 'de');
	'rmyg' = ('en', 'de');
	'rmyh' = ('en', 'de', 'hu');
	'rmyk' = ('en', 'de', 'ro', 'ru', 'sr');
	'rmyl' = ('en', 'de', 'hu');
	'rmys' = ('en', 'de', 'sr');
	'roml' = ('en', 'de', 'lv', 'ru');
	'romr' = ('en', 'de', 'ru');
	'romt' = ('en', 'ru');
};

$progress = 0;
$total = 0;
foreach ($dk in $dialects.Keys) {
	$total += $letters.Count * $dialects[$dk].Count;
}

foreach ($cl1 in $dialects.Keys) {
	foreach ($cl2 in $dialects[$cl1]) {
		$content = "";
		$index = 0;
		
		foreach ($st in $letters) {
			Start-Sleep -Seconds 0.5;
			
			$progressPercent = (++$progress) / $total * 100;
			$progressStatus = [string]::Format("{0}-{1} [{2}/{3}] [{4}%]", $cl1, $cl2,
				$progress, $total, [math]::Round($progressPercent));
			Write-Progress -Activity "Parsing" -Status $progressStatus -PercentComplete $progressPercent;
			
			$uri = "http://romani.uni-graz.at/romlex/lex.cgi?st={0}&rev=n&cl1={1}&cl2={2}&fi=&pm=pr&ic=y&im=y&wc=";
			$requestUri = [string]::Format($uri, $st, $cl1, $cl2);
			
			$response = Invoke-RestMethod -Uri $requestUri;
			
			foreach ($entry in $response.romlex.dict.entry) {
				$cols = @();
				
				$cols += (++$index);
				
				foreach ($data in ($entry.o, $entry.pos, $entry.aff)) {
					$str = "";
					
					foreach ($val in $data) {
						if (![string]::IsNullOrEmpty($str)) {
							$str += ", ";
						}
						$str += $val;
					}
					
					$str = $str.Replace("`"", "'").Replace("`r", "").Replace("`n", "");
					$cols += ($str, "`"$str`"")[$str -and $str.Contains(",")];
				}
				
				$sum = "";
				
				$gAmount = ($entry.g | Measure-Object).Count;
				$defIndex = 1;
				
				foreach ($g in $entry.g) {
					if ($gAmount -gt 1) {
						if (![string]::IsNullOrEmpty($sum)) {
							$sum += " ";
						}
						$sum += [string]::Format("{0}. ", $defIndex++);
					}
					
					$data = @();
					$data += , $g.s;
					
					foreach ($p in $g.s.p) {
						$data += , $p;
					}
					
					for ($i = 0; $i -lt $data.Count; $i++) {
						if (($i -gt 0) -and [string]::IsNullOrEmpty($data[$i].o)) {
							continue;
						}
						
						$str = "";
						
						foreach ($t in $data[$i].t) {
							if (![string]::IsNullOrEmpty($str)) {
								$str += ", ";
							}
							$str += $t.e;
							
							if ($t.h) {
								$str += " (" + $t.h + ")";
							}
							
							if ($t.d) {
								if (![string]::IsNullOrEmpty($str)) {
									$str += " ";
								}
								$str += $t.d;
							}
						}
						
						$sum += ($str, (" [«" + $data[$i].o + "» - " + $str + "]"))[$i -gt 0];
					}
				}
				
				$sum = $sum.Replace("`"", "'").Replace("`r", "").Replace("`n", "");
				$cols += ($sum, "`"$sum`"")[$sum -and $sum.Contains(",")];
				
				$form = [system.String]::Join(",", ((0..($cols.Count - 1)) | ForEach-Object {"{$_}"})) + "`r`n";
				$content += [string]::Format($form, $cols);
			}
		}
		
		if (![string]::IsNullOrEmpty($content)) {
			if (!(Test-Path ($output + "\" + $cl1) -PathType "Container")) {
				[void](New-Item -ItemType "Directory" -Force -Path ($output + "\" + $cl1));
			}
			
			$path = $output + "\" + $cl1 + "\" + $cl2 + ".csv";
			$content = "Index,Entry Word,Part of Speech,Affix,Definition`r`n" + $content;
			
			[IO.File]::WriteAllLines($path, $content);
		}
	}
}