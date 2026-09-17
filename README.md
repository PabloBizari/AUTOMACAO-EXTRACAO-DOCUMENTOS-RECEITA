Automação desenvolvida em PowerShell, com o uso de Inteligência Artificial (IA) como apoio no desenvolvimento e aprimoramento da solução, para localizar e transferir documentos de Receita com base nos números de propostas informados pelo usuário.

A ferramenta recebe uma lista de propostas e pesquisa, uma por uma, as pastas correspondentes em um caminho de origem específico. Para cada pasta encontrada, a automação verifica recursivamente se existe algum arquivo com o termo “Receita” em seu nome.

Quando um documento é localizado, ele é copiado para uma pasta de destino e renomeado automaticamente no padrão:

CPF_RECEITA_NÚMERO_DA_PROPOSTA.extensão

A proposta completa e o CPF são obtidos a partir do nome da pasta de origem. Caso a proposta informada tenha menos de nove dígitos, a automação também realiza a busca com zeros adicionados à esquerda. Dessa forma, a solução reduz buscas manuais, padroniza a nomenclatura dos arquivos e agiliza a organização dos documentos de Receita.

