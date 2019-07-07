<#
									
	 Script Desenvolvido por		
									
		  João Loriato				
									
  Github: github.com/JoaoLoriato   
                                   
            02/07/2019             
									
			 V.01                   
#>
	
#EXECUTAR O SCRIPT COMO ADMINISTRADOR
	
if (!(net session)) {$path =  "& '" + $myinvocation.mycommand.definition + "'" ; Start-Process powershell -Verb runAs -ArgumentList $path ; exit}
	
#USUÁRIO E SENHA PARA ACESSO AOS SERVIDORES

$Username = "USERAD\jhenriql"
$Pass = Get-Content "\NAGBR_WIN.txt"
$Secure = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($Pass))
$Password = $Secure|ConvertTo-SecureString -AsPlainText -Force
write-host $Username
write-host $Password
$Credential = New-Object System.Management.Automation.PSCredential($Username,$Password)
	
#WORKERS e IP's

#SUL

$ARGENTINA="10.106.229.130"
$BRASIL="10.106.229.50"
$CHILE="10.106.229.82"
$COMUMAPPSUR="10.106.229.74"
$GESTIONBR="10.106.229.66"
$PARAGUAI="10.106.229.122"
$URUGUAI="10.106.229.98"
$TESTE="192.168.15.252"

#NORTE

$ASSISTENCIA="10.119.241.54"
$COLOMBIA="10.119.241.30"
$COMUMUSA="10.119.241.62"
$COSTARICA="10.119.241.70"
$ECUADOR="10.119.241.37"
$GUATEMALA="10.119.241.78"
$HONDURAS="10.119.241.118"
$MEXICO="10.119.241.22"
$NICARAGUA="10.119.241.86"
$PANAMA="10.119.241.130"
$PERU="10.119.241.14"
$PORTORICO="10.119.241.6"
$RD="10.119.241.46"
$ROADAMERICA="10.119.241.62"
$SOLUNION="10.119.241.102"
$GESTIONUS="10.119.241.94"
$VENEZUELA="10.119.1.110"
		
#PERGUNTA AO USUÁRIO O NOME DO HOST
$in_host = read-host "Informe o nome do host ou IP (ex: LBR001001-003 ou 192.168.200.0)"

#PERGUNTA AO USUÁRIO O NOME DO PAIS
$in_worker = read-host "Informe o pais do host (ex: BRASIL sem caracter especial)"

#ALTERA O NOME DO PAIS PARA O IP DO WORKER
		
	#SUL
		
	if ($in_worker -eq "ARGENTINA"){
		$worker=$ARGENTINA
	}
	if ($in_worker -eq "BRASIL"){
		$worker=$BRASIL
	}
	if ($in_worker -eq "CHILE"){
		$worker=$CHILE
	}
	if ($in_worker -eq "COMUMAPPSUR"){
		$worker=$COMUMAPPSUR
	}
	if ($in_worker -eq "GESTIONBR"){
		$worker=$GESTIONBR
	}
	if ($in_worker -eq "PARAGUAI"){
		$worker=$PARAGUAI
	}
	if ($in_worker -eq "URUGUAI"){
		$worker=$URUGUAI
	}
	
	#NORTE
	
	if ($in_worker -eq "ASSISTENCIA"){
		$worker=$ASSISTENCIA
	}
	if ($in_worker -eq "COLOMBIA"){
		$worker=$COLOMBIA
	}
	if ($in_worker -eq "COMUMUSA"){
		$worker=$COMUMUSA
	}
	if ($in_worker -eq "COSTARICA"){
		$worker=$COSTARICA
	}
	if ($in_worker -eq "ECUADOR"){
		$worker=$ECUADOR
	}
	if ($in_worker -eq "GESTIONUS"){
		$worker=$GESTIONUS
	}
	if ($in_worker -eq "GUATEMALA"){
		$worker=$GUATEMALA
	}
	if ($in_worker -eq "HONDURAS"){
		$worker=$HONDURAS
	}
	if ($in_worker -eq "MEXICO"){
		$worker=$MEXICO
	}
	if ($in_worker -eq "NICARAGUA"){
		$worker=$NICARAGUA
	}
	if ($in_worker -eq "PANAMA"){
		$worker=$PANAMA
	}
	if ($in_worker -eq "PERU"){
		$worker=$PERU
	}
	if ($in_worker -eq "PORTORICO"){
		$worker=$PORTORICO
	}
	if ($in_worker -eq "RD"){
		$worker=$RD
	}
	if ($in_worker -eq "ROADAMERICA"){
		$worker=$ROADAMERICA
	}
	if ($in_worker -eq "SOLUNION"){
		$worker=$SOLUNION
	}
	if ($in_worker -eq "VENEZUELA"){
		$worker=$VENEZUELA
	}

#PERGUNTA AO USUÁRIO SE AS INFORMAÇÕES ESTÃO CORRETAS E DESEJA CONTINUAR

write-host "Valide se as informacoes estao corretas"  `n
write-host "Nome do host: $in_host , Nome do pais: $in_worker "  `n
$in_escolha = read-host "Deseja continuar? (Y/N)"

#CASO ELE ESCOLHA A OPÇÃO Y IRÁ REALIZAR OS 3 TESTES

if ($in_escolha -eq "Y"){
	
	write-host "Reiniciando o agente Nagios"
	write-host "Por favor aguarde"  `n
			
	#REINICIAR O SERVIÇO NRPE
			
	try{
		$out_stop = Invoke-Command -ComputerName $in_host -Credential $Credential -ScriptBlock {Stop-Service -inputobject $(get-service -Name 'nscp')}
		$out_start = Invoke-Command -ComputerName $in_host -Credential $Credential -ScriptBlock {Start-Service -inputobject $(get-service -Name 'nscp')}
		$out_status = Invoke-Command -ComputerName $in_host -Credential $Credential -ScriptBlock {get-service -Name 'nscp'}
		#$out_stop = get-service -ComputerName $in_host -Name nscp | Stop-Service
		#$out_start = get-service -ComputerName $in_host -Name nscp | Start-Service
		#$out_status = get-service -ComputerName $in_host -Name nscp 
	
	#CASO NÃO CONSIGA, IRÁ ENVIAR EMAIL PARA O ESPECIALISTA NAGIOS
	
		if ($error.Exception -match "Microsoft.PowerShell.Commands.ServiceCommandException"){
			write-host $error
			write-host $out_stop
			write-host $out_start
			write-host $out_status
			get-service -ComputerName $in_host -Name nscp
			write-host "Nao foi possivel reiniciar o agente Nagios"
			write-host "Enviar email para o especialista Nagios"
			write-host "Aperte Enter para encerrar..."
			[void][System.Console]::ReadKey($true)
		}
		else{
			write-host "Agente reiniciado com sucesso."
			get-service -ComputerName $in_host -Name nscp
			write-host $out_stop
			write-host $out_start
			write-host $out_status
			write-host "Aperte Enter para encerrar..."
			[void][System.Console]::ReadKey($true)
			exit
		}
	}
		catch{
			write-host $error
			write-host $out_stop
			write-host $out_start
			write-host $out_status
			write-host "$error"
			write-host "Nao foi possivel reiniciar o agente Nagios"
			write-host "Enviar email para o especialista Nagios"
			write-host "Aperte Enter para encerrar..."
			[void][System.Console]::ReadKey($true)
		}
}

else {
	write-host "Tente novamente";
	exit
}