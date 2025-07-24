import QtQuick
import QtQuick.Effects
import qs.config

RectangularShadow {
    required property var target
    anchors.fill: target
    radius: target.radius
    blur: 0.9 * 10 // TODO: Valeur en dur car sinon il faut l'import de Appearance.sizes.elevationMargin
    offset: Qt.vector2d(0.0, 1.0)
    spread: 1
    color: "red" // TODO: remplacer par Colors. Valeur en dur pour eviter la dependance a Appearance.colors.colShadow
    cached: true
}
