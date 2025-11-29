Aqui estarão os métodos de uso do App - Offline-first, pertinentes ao DB local(sqlite)

Métodos:

Criar DB local(sqlite).

Sincronizar dados das coleções - person, property, producer, producer_property. DB(firestore) -> DB(sqlite).
(A fim de, quando o Coletor estiver offline o mesmo ainda consegue buscar produtore(por nome e nome da propriedade) para cadastrar uma nova coleta).

Sincronizar dados de coleta - DB(sqlite) -> DB(firestore).
(Sincronizar as coletas salvas no banco local(terão a coluna synced=false, após enviar os dados para a API para sincronizar com o DB(firestore) recebe synced=true e no firestore recebe syncedAt=DateTime)).