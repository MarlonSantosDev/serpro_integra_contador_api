namespace Serpro.Componentes.AssinaturaDigital
{
    public class Result
    {
        public bool Success { get; }
        public bool Fail { get; }
        public int Code { get; }
        public string Message { get; }

        public Result(bool success)
        {
            Success = success;
            Fail = !success;
        }

        public Result(bool success, int code) : this(success) =>
            Code = code;

        public Result(bool success, string message) : this(success) =>
            Message = message;

        public Result(bool success, int code, string message) : this(success)
        {
            Code = code;
            Message = message;
        }
    }
}