// ignore_for_file: avoid_print, non_constant_identifier_names



// CLASES DE PERSONAS REALES
class Eventos {
  final int Id;
  final String Nombre;
  final String Descripcion;
  final String FechaInicio;
  final String FechaFin;
  final int IdUsuario;
  final int IdCreador;
  final bool Visible;
  final int IdEtiqueta;

  Eventos(
      {required this.Id,
      required this.Nombre,
      required this.Descripcion,
      required this.FechaInicio,
      required this.FechaFin,
      required this.IdUsuario,
      required this.IdCreador,
      required this.Visible,
      required this.IdEtiqueta});
}

class ServicioEventos {}
