extends Node2D

const TILE := 16
const MAP_W := 40
const MAP_H := 24
const TEX := preload("res://sprites/tiny-town.png")

var chao: TileMapLayer
var objetos: TileMapLayer
var tileset: TileSet
var atlas: TileSetAtlasSource

func _ready() -> void:
    _criar_tileset()
    _criar_camadas()
    _pintar_chao()
    _pintar_objetos()
    _criar_colisoes()

func _criar_tileset() -> void:
    tileset = TileSet.new()
    tileset.tile_size = Vector2i(TILE, TILE)
    tileset.add_physics_layer()

    atlas = TileSetAtlasSource.new()
    atlas.texture = TEX
    atlas.texture_region_size = Vector2i(TILE, TILE)

    var casas := [Vector2i(0, 4), Vector2i(4, 4)]
    var arvores_altas := [Vector2i(3, 0), Vector2i(4, 0)]

    for y in range(11):
        for x in range(12):
            var c := Vector2i(x, y)
            var dentro_casa := (x >= 0 and x <= 3 and y >= 4 and y <= 6) or (x >= 4 and x <= 7 and y >= 4 and y <= 6)
            var arvore_grande := (x == 3 or x == 4) and y <= 1
            if dentro_casa or arvore_grande:
                continue
            atlas.create_tile(c)

    atlas.create_tile(Vector2i(0, 4), Vector2i(4, 3))
    atlas.create_tile(Vector2i(4, 4), Vector2i(4, 3))
    atlas.create_tile(Vector2i(3, 0), Vector2i(1, 2))
    atlas.create_tile(Vector2i(4, 0), Vector2i(1, 2))

    tileset.add_source(atlas, 0)

func _criar_camadas() -> void:
    chao = TileMapLayer.new()
    chao.name = "chao"
    chao.tile_set = tileset
    chao.z_index = 0
    add_child(chao)

    objetos = TileMapLayer.new()
    objetos.name = "objetos"
    objetos.tile_set = tileset
    objetos.z_index = 0
    add_child(objetos)

func _pintar_chao() -> void:
    # Grama em todo o mapa.
    for y in range(MAP_H):
        for x in range(MAP_W):
            chao.set_cell(Vector2i(x, y), 0, Vector2i(0, 0))

    # Variações de grama.
    for p in [Vector2i(4,3), Vector2i(7,18), Vector2i(13,5), Vector2i(28,4), Vector2i(34,18), Vector2i(22,20), Vector2i(2,15)]:
        chao.set_cell(p, 0, Vector2i(1, 0))
    for p in [Vector2i(15,3), Vector2i(30,20), Vector2i(37,8), Vector2i(5,21), Vector2i(25,6)]:
        chao.set_cell(p, 0, Vector2i(2, 0))

    # Rua horizontal de 3 células de altura.
    for x in range(MAP_W):
        chao.set_cell(Vector2i(x, 10), 0, Vector2i(1, 1))
        chao.set_cell(Vector2i(x, 11), 0, Vector2i(1, 2))
        chao.set_cell(Vector2i(x, 12), 0, Vector2i(1, 3))
    # Pontas da rua horizontal.
    chao.set_cell(Vector2i(0,10),0,Vector2i(0,1)); chao.set_cell(Vector2i(MAP_W-1,10),0,Vector2i(2,1))
    chao.set_cell(Vector2i(0,11),0,Vector2i(0,2)); chao.set_cell(Vector2i(MAP_W-1,11),0,Vector2i(2,2))
    chao.set_cell(Vector2i(0,12),0,Vector2i(0,3)); chao.set_cell(Vector2i(MAP_W-1,12),0,Vector2i(2,3))

    # Rua vertical de 3 células de largura.
    for y in range(MAP_H):
        chao.set_cell(Vector2i(18,y),0,Vector2i(0,2))
        chao.set_cell(Vector2i(19,y),0,Vector2i(1,2))
        chao.set_cell(Vector2i(20,y),0,Vector2i(2,2))
    # Cantos das pontas da rua vertical.
    chao.set_cell(Vector2i(18,0),0,Vector2i(0,1)); chao.set_cell(Vector2i(19,0),0,Vector2i(1,1)); chao.set_cell(Vector2i(20,0),0,Vector2i(2,1))
    chao.set_cell(Vector2i(18,MAP_H-1),0,Vector2i(0,3)); chao.set_cell(Vector2i(19,MAP_H-1),0,Vector2i(1,3)); chao.set_cell(Vector2i(20,MAP_H-1),0,Vector2i(2,3))
    # Cruzamento sem borda.
    for y in range(10,13):
        for x in range(18,21):
            chao.set_cell(Vector2i(x,y),0,Vector2i(1,2))

func _pintar_objetos() -> void:
    # Casas inteiras como uma única peça.
    objetos.set_cell(Vector2i(8,6), 0, Vector2i(0,4))
    objetos.set_cell(Vector2i(30,6), 0, Vector2i(4,4))
    objetos.set_cell(Vector2i(8,18), 0, Vector2i(4,4))
    objetos.set_cell(Vector2i(30,18), 0, Vector2i(0,4))

    # Árvores altas.
    for p in [Vector2i(4,6), Vector2i(34,5), Vector2i(35,20)]:
        objetos.set_cell(p,0,Vector2i(3,0))
    for p in [Vector2i(14,20), Vector2i(26,4), Vector2i(36,15)]:
        objetos.set_cell(p,0,Vector2i(4,0))

    # Árvores pequenas e arbustos.
    for p in [Vector2i(2,5),Vector2i(12,4),Vector2i(32,3),Vector2i(37,20),Vector2i(3,19)]:
        objetos.set_cell(p,0,Vector2i(3,2))
    for p in [Vector2i(6,3),Vector2i(15,6),Vector2i(25,3),Vector2i(35,8),Vector2i(4,21),Vector2i(33,21)]:
        objetos.set_cell(p,0,Vector2i(5,0))

    # Poço e placa perto das ruas.
    objetos.set_cell(Vector2i(16,8),0,Vector2i(8,8))
    objetos.set_cell(Vector2i(22,9),0,Vector2i(11,6))

    # Cerca em torno de uma pequena horta.
    for x in range(25,29):
        objetos.set_cell(Vector2i(x,15),0,Vector2i(9 if x not in [25,28] else (8 if x == 25 else 10),6))
    objetos.set_cell(Vector2i(25,16),0,Vector2i(11,4))
    objetos.set_cell(Vector2i(25,17),0,Vector2i(11,4))
    objetos.set_cell(Vector2i(25,18),0,Vector2i(11,5))

    # Muro em toda a volta.
    for x in range(MAP_W):
        objetos.set_cell(Vector2i(x,0),0,Vector2i(6,10))
        objetos.set_cell(Vector2i(x,MAP_H-1),0,Vector2i(6,10))
    for y in range(1,MAP_H-1):
        objetos.set_cell(Vector2i(0,y),0,Vector2i(6,10))
        objetos.set_cell(Vector2i(MAP_W-1,y),0,Vector2i(6,10))

func _criar_colisoes() -> void:
    # Casas: 4x3 células = 64x48 px.
    for pos in [Vector2(128,96),Vector2(480,96),Vector2(128,288),Vector2(480,288)]:
        _retangulo_colisao(pos, Vector2(64,48), "Casa")

    # Árvores altas e pequenas.
    for pos in [Vector2(72,104),Vector2(552,88),Vector2(568,328),Vector2(232,328),Vector2(424,72),Vector2(584,248)]:
        _retangulo_colisao(pos, Vector2(16,32), "Arvore")
    for pos in [Vector2(40,88),Vector2(200,72),Vector2(520,56),Vector2(600,328),Vector2(56,312)]:
        _retangulo_colisao(pos, Vector2(16,16), "ArvorePequena")
    for pos in [Vector2(104,56),Vector2(248,104),Vector2(408,56),Vector2(568,136),Vector2(72,344),Vector2(536,344)]:
        _retangulo_colisao(pos, Vector2(16,16), "Arbusto")

    # Poço, placa e cerca.
    _retangulo_colisao(Vector2(264,136),Vector2(16,16),"Poco")
    _retangulo_colisao(Vector2(360,152),Vector2(16,16),"Placa")
    for x in [25,26,27,28]:
        _retangulo_colisao(Vector2(x*16+8,15*16+8),Vector2(16,8),"Cerca")
    for y in [16,17,18]:
        _retangulo_colisao(Vector2(25*16+8,y*16+8),Vector2(8,16),"Cerca")

    # Muro contínuo.
    _retangulo_colisao(Vector2(320,8),Vector2(640,16),"Muro")
    _retangulo_colisao(Vector2(320,376),Vector2(640,16),"Muro")
    _retangulo_colisao(Vector2(8,192),Vector2(16,352),"Muro")
    _retangulo_colisao(Vector2(632,192),Vector2(16,352),"Muro")

func _retangulo_colisao(pos: Vector2, tamanho: Vector2, nome: String) -> void:
    var corpo := StaticBody2D.new()
    corpo.name = nome
    var forma := CollisionShape2D.new()
    var rect := RectangleShape2D.new()
    rect.size = tamanho
    forma.shape = rect
    corpo.position = pos
    corpo.add_child(forma)
    add_child(corpo)
