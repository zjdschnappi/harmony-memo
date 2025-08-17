
export interface IMemoRouteParam {
  id: string
}

export interface IColorItemParams {
  color:Color
  onClick:(item:Color)=>void
  active?:boolean
}

export interface ITextDecoratorItem{
  icon: Resource;
  onClick:()=>void;
  active?:boolean;
}
export interface ITextColorItem{
  color: Color;
}
export interface ITypingStyleParam{
  textColor?: Color;
  fontSize?: number;
  isBold?: boolean;
  isItalic?: boolean;
  isUnderline?: boolean;
}
